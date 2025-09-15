<?php
header('Content-Type: text/html; charset=utf-8');

function getCurrencyRates() {
    $cbrUrl = 'https://www.cbr-xml-daily.ru/daily_json.js';
    
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $cbrUrl);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
    curl_setopt($ch, CURLOPT_TIMEOUT, 10);

    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);

    if ($httpCode === 200 && $response !== false) {
        return json_decode($response, true);
    }
    
    return null;
}

function createCSV($data) {
    if (!$data || !isset($data['Valute'])) {
        return false;
    }

    $csvData = "Валюта,Код,Номинал,Курс,Изменение\n";
    
    foreach ($data['Valute'] as $currency) {
        $csvData .= sprintf(
            "%s,%s,%d,%.4f,%.4f\n",
            $currency['Name'],
            $currency['CharCode'],
            $currency['Nominal'],
            $currency['Value'],
            $currency['Previous'] - $currency['Value']
        );
    }
    
    return $csvData;
}

function sendEmail($email, $csvData, $date) {
    $subject = "Курсы валют ЦБ РФ на " . $date;
    $message = "Во вложении CSV файл с курсами валют ЦБ РФ на " . $date;
    
    $boundary = uniqid();
    $headers = [
        "From: currency-bot@yourdomain.com",
        "Reply-To: currency-bot@yourdomain.com",
        "MIME-Version: 1.0",
        "Content-Type: multipart/mixed; boundary=\"$boundary\""
    ];

    $body = "--$boundary\r\n";
    $body .= "Content-Type: text/plain; charset=utf-8\r\n";
    $body .= "Content-Transfer-Encoding: base64\r\n\r\n";
    $body .= base64_encode($message) . "\r\n";
    
    $body .= "--$boundary\r\n";
    $body .= "Content-Type: text/csv; name=\"currency_rates_$date.csv\"\r\n";
    $body .= "Content-Transfer-Encoding: base64\r\n";
    $body .= "Content-Disposition: attachment\r\n\r\n";
    $body .= base64_encode($csvData) . "\r\n";
    $body .= "--$boundary--";

    return mail($email, $subject, $body, implode("\r\n", $headers));
}

$message = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (isset($_POST['get_rates'])) {
        // Просто показываем курсы
        $currencyData = getCurrencyRates();
    } elseif (isset($_POST['send_email']) && !empty($_POST['email'])) {
        $email = filter_var($_POST['email'], FILTER_SANITIZE_EMAIL);
        
        if (filter_var($email, FILTER_VALIDATE_EMAIL)) {
            $currencyData = getCurrencyRates();
            
            if ($currencyData) {
                $csvData = createCSV($currencyData);
                
                if ($csvData && sendEmail($email, $csvData, $currencyData['Date'])) {
                    $message = "✅ Курсы валют отправлены на email: $email";
                } else {
                    $message = "❌ Ошибка при отправке email";
                }
            } else {
                $message = "❌ Не удалось получить курсы валют";
            }
        } else {
            $message = "❌ Неверный формат email адреса";
        }
    }
}

// Получаем данные для отображения
if (!isset($currencyData)) {
    $currencyData = getCurrencyRates();
}
?>

<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Курсы валют ЦБ РФ</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .container { max-width: 800px; margin: 0 auto; }
        .form-group { margin: 15px 0; }
        input[type="email"] { 
            padding: 8px; 
            width: 300px; 
            border: 1px solid #ccc; 
            border-radius: 4px; 
        }
        button { 
            padding: 10px 20px; 
            margin: 5px; 
            border: none; 
            border-radius: 4px; 
            cursor: pointer; 
        }
        .btn-get { background: #4CAF50; color: white; }
        .btn-send { background: #2196F3; color: white; }
        .message { padding: 10px; margin: 10px 0; border-radius: 4px; }
        .success { background: #d4edda; color: #155724; }
        .error { background: #f8d7da; color: #721c24; }
        table { width: 100%; border-collapse: collapse; margin: 20px 0; }
        th, td { padding: 10px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background: #f5f5f5; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Курсы валют ЦБ РФ</h1>
        
        <?php if ($message): ?>
            <div class="message <?php echo strpos($message, '✅') !== false ? 'success' : 'error'; ?>">
                <?php echo htmlspecialchars($message); ?>
            </div>
        <?php endif; ?>

        <form method="post">
            <div class="form-group">
                <button type="submit" name="get_rates" class="btn-get">Получить курсы валют</button>
            </div>
            
            <div class="form-group">
                <input type="email" name="email" placeholder="Введите email для отправки" required>
                <button type="submit" name="send_email" class="btn-send">Отправить курсы валют на почту</button>
            </div>
        </form>

        <?php if ($currencyData && isset($currencyData['Valute'])): ?>
            <h2>Курсы на <?php echo date('d.m.Y', strtotime($currencyData['Date'])); ?></h2>
            <table>
                <thead>
                    <tr>
                        <th>Валюта</th>
                        <th>Код</th>
                        <th>Номинал</th>
                        <th>Курс</th>
                        <th>Изменение</th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($currencyData['Valute'] as $currency): ?>
                        <tr>
                            <td><?php echo htmlspecialchars($currency['Name']); ?></td>
                            <td><?php echo htmlspecialchars($currency['CharCode']); ?></td>
                            <td><?php echo $currency['Nominal']; ?></td>
                            <td><?php echo number_format($currency['Value'], 4); ?></td>
                            <td style="color: <?php echo ($currency['Value'] - $currency['Previous']) >= 0 ? 'green' : 'red'; ?>">
                                <?php echo number_format($currency['Value'] - $currency['Previous'], 4); ?>
                            </td>
                        </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        <?php elseif (!isset($_POST['send_email'])): ?>
            <p>Не удалось загрузить курсы валют. Попробуйте обновить страницу.</p>
        <?php endif; ?>
    </div>
</body>
</html>
