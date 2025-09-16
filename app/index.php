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

$currencyData = getCurrencyRates();
?>

<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <title>Курсы валют ЦБ РФ</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chartjs-adapter-date-fns"></script>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background: #f7f9fc; color: #333; }
        .container { max-width: 1200px; margin: 0 auto; display: flex; gap: 30px; }
        .left { flex: 1; background: #fff; padding: 20px; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.05); }
        .right { flex: 2; background: #fff; padding: 20px; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.05); }
        .form-group { margin: 15px 0; }
        table { width: 100%; border-collapse: collapse; margin: 20px 0; }
        th, td { padding: 8px; border-bottom: 1px solid #ddd; }
        th { background: #f0f2f5; }
        button { padding: 10px 15px; border: none; background: #4a90e2; color: white; border-radius: 5px; cursor: pointer; margin-right: 10px; }
        button:hover { background: #357abd; }
        canvas { width: 100%; height: 400px; }
        #saveChart { margin-top: 15px; background: #28a745; }
        #saveChart:hover { background: #218838; }
        #saveCSV { margin-top: 15px; background: #ff9800; }
        #saveCSV:hover { background: #e68900; }
    </style>
</head>
<body>
<div class="container">
    <div class="left">
        <h2>Курсы валют</h2>
        <?php if ($currencyData && isset($currencyData['Valute'])): ?>
            <table>
                <thead>
                <tr>
                    <th>Валюта</th>
                    <th>Код</th>
                    <th>Курс</th>
                </tr>
                </thead>
                <tbody>
                <?php foreach ($currencyData['Valute'] as $currency): ?>
                    <tr>
                        <td><?php echo htmlspecialchars($currency['Name']); ?></td>
                        <td><?php echo htmlspecialchars($currency['CharCode']); ?></td>
                        <td><?php echo number_format($currency['Value'], 4); ?></td>
                    </tr>
                <?php endforeach; ?>
                </tbody>
            </table>

            <h3>Выбор валюты для графика</h3>
            <div class="form-group">
                <?php foreach ($currencyData['Valute'] as $code => $currency): ?>
                    <label>
                        <input type="checkbox" class="currencyCheckbox" value="<?php echo $code; ?>">
                        <?php echo $currency['Name']; ?> (<?php echo $currency['CharCode']; ?>)
                    </label><br>
                <?php endforeach; ?>
            </div>

            <div class="form-group">
                <label>С даты: <input type="date" id="dateFrom"></label>
                <label>По дату: <input type="date" id="dateTo"></label>
            </div>

            <button id="showChart">Показать график</button>
        <?php else: ?>
            <p>Не удалось загрузить данные ЦБ.</p>
        <?php endif; ?>
    </div>

    <div class="right">
        <h2>График изменения курса</h2>
        <canvas id="chart"></canvas>
        <div>
            <button id="saveChart">Сохранить график</button>
            <button id="saveCSV">Сохранить данные (CSV)</button>
        </div>
    </div>
</div>

<script>
const ctx = document.getElementById('chart').getContext('2d');
let chart;
let lastData = {}; // для хранения последних загруженных данных

// 🎨 Палитра цветов
const colors = [
    '#4a90e2', '#e94e77', '#50e3c2', '#f5a623',
    '#9013fe', '#b8e986', '#d0021b', '#7ed321',
    '#f8e71c', '#417505'
];

async function loadHistory(currencies, from, to) {
    const datasets = [];
    lastData = {}; // обнуляем перед загрузкой
    let colorIndex = 0;

    for (let code of currencies) {
        const responses = [];

        let start = new Date(from);
        let end = new Date(to);

        while (start <= end) {
            let y = start.getFullYear();
            let m = String(start.getMonth()+1).padStart(2,'0');
            let d = String(start.getDate()).padStart(2,'0');

            try {
                let res = await fetch(`https://www.cbr-xml-daily.ru/archive/${y}/${m}/${d}/daily_json.js`);
                if (res.ok) {
                    let data = await res.json();
                    if (data.Valute && data.Valute[code]) {
                        responses.push({
                            date: new Date(data.Date).toISOString().split('T')[0],
                            value: data.Valute[code].Value
                        });
                    }
                }
            } catch(e) {
                console.log("Ошибка загрузки для даты", y,m,d);
            }

            start.setDate(start.getDate() + 1);
        }

        lastData[code] = responses;

        datasets.push({
            label: code,
            data: responses.map(r => ({x: r.date, y: r.value})),
            borderColor: colors[colorIndex % colors.length],
            backgroundColor: colors[colorIndex % colors.length],
            borderWidth: 2,
            tension: 0.2,
            fill: false
        });

        colorIndex++;
    }

    if (chart) chart.destroy();
    chart = new Chart(ctx, {
        type: 'line',
        data: { datasets },
        options: {
            responsive: true,
            plugins: { legend: { position: 'bottom' } },
            scales: {
                x: { type: 'time', time: { unit: 'day' } },
                y: { beginAtZero: false }
            }
        }
    });
}

// 📈 Показать график
document.getElementById("showChart").addEventListener("click", () => {
    const checkboxes = document.querySelectorAll(".currencyCheckbox:checked");
    const currencies = Array.from(checkboxes).map(cb => cb.value);

    const from = document.getElementById("dateFrom").value;
    const to = document.getElementById("dateTo").value;

    if (currencies.length && from && to) {
        loadHistory(currencies, from, to);
    } else {
        alert("Выберите валюты и диапазон дат");
    }
});

// 💾 Сохранение графика
document.getElementById("saveChart").addEventListener("click", () => {
    if (!chart) {
        alert("Сначала постройте график!");
        return;
    }
    const link = document.createElement("a");
    link.href = chart.toBase64Image();
    link.download = "currency_chart.png";
    link.click();
});

// 📊 Сохранение данных в CSV
document.getElementById("saveCSV").addEventListener("click", () => {
    if (!Object.keys(lastData).length) {
        alert("Сначала постройте график!");
        return;
    }

    let csv = "Дата," + Object.keys(lastData).join(",") + "\n";

    // Собираем все даты
    let allDates = new Set();
    for (let code in lastData) {
        lastData[code].forEach(r => allDates.add(r.date));
    }
    let dates = Array.from(allDates).sort();

    // Заполняем строки
    for (let date of dates) {
        let row = [date];
        for (let code in lastData) {
            let rec = lastData[code].find(r => r.date === date);
            row.push(rec ? rec.value : "");
        }
        csv += row.join(",") + "\n";
    }

    // Скачивание
    const blob = new Blob([csv], { type: "text/csv" });
    const link = document.createElement("a");
    link.href = URL.createObjectURL(blob);
    link.download = "currency_data.csv";
    link.click();
});

// ⚡ Автозагрузка (USD, EUR, CNY за 30 дней)
window.addEventListener("DOMContentLoaded", () => {
    const defaultCurrencies = ["USD", "EUR", "CNY"];
    document.querySelectorAll(".currencyCheckbox").forEach(cb => {
        if (defaultCurrencies.includes(cb.value)) cb.checked = true;
    });

    let today = new Date();
    let past = new Date();
    past.setDate(today.getDate() - 30);

    document.getElementById("dateFrom").value = past.toISOString().split('T')[0];
    document.getElementById("dateTo").value = today.toISOString().split('T')[0];

    loadHistory(defaultCurrencies,
        document.getElementById("dateFrom").value,
        document.getElementById("dateTo").value);
});
</script>
</body>
</html>
