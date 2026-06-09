# Analytic-SQL-Amazon-e-commerce
# Оптимізація маржинальності асортименту e-commerce бренду на Amazon

## 📊 Резюме по кейсу (STAR Кейс)

*   **Situation (Ситуація):** Компанія здійснює торгівлю одягом через платформу Amazon з річним оборотом понад $80 млн. Найбільша за обсягами категорія товару — `Set` — генерує майже половину всього виторгу (39.20 млн). Проте через відсутність консолідації даних керівництво не мало точних цифр щодо реального чистого прибутку з урахуванням логістики та собівартості.
*   **Task (Завдання):** Об'єднати розрізнені сирі дані транзакцій з даними фінансової собівартості. Розрахувати чистий прибуток (`Profit`) для кожної категорії, локалізувати збитки та розробити антикризову стратегію.
*   **Action (Дії):** 
    1.  **SQL (PostgreSQL):** Розгорнув локальну базу даних, розробив скрипти для очищення текстових аномалій та парсингу різноформатних дат.
    2.  **Data Pipeline:** Створив систему автоматичних представлень (**SQL Views**) для побудови стабільного пайплайну оновлення даних між сервером та BI-системою.
    3.  **Power BI:** Розробив інтерактивний дашборд з умовним форматуванням, провів розширений Time-Series аналіз та гео-аналітику за штатами (`Ship State`).
*   **Result (Результат):** Виявив, що категорія-лідер `Set` є планово-збитковою і приносить чистий збиток у розмірі **-5.48 млн** (ROI:-12.2%). Збитки локалізовано у пікові місяці (квітень-травень 2022) та у конкретних регіонах — штатах **Maharashtra** та **Karnataka**. Сформулював рекомендації щодо зміни цінової політики на 15-20% у збиткових зонах та переспрямування маркетингу на високомаржинальну категорію `Western Dress` (+ 5.51 млн прибутку в тих самих локаціях).

---

## 🛠️ Технічний стек

*   **Database:** PostgreSQL (DBeaver)
*   **BI-Tools:** Power BI Desktop (DAX, Power Query)
*   **Language:** SQL (DQL, DDL)

---

## 💻 Реалізація (Приклади коду)

### Очищення та трансформація дат в SQL View
Для синхронізації даних та обробки змішаних форматів дат (`DD.MM.YYYY` та `MM-DD-YY`) було використано таку логіку:

```sql
--VIEW для синхронізації з Power BI--
CREATE OR REPLACE VIEW sync_pbi_script_3_set_delta AS
SELECT 
--Логіка перетворення формату дати--
    to_char(
        CASE 
            WHEN ps."Date" LIKE '%.%' THEN to_date(ps."Date", 'DD.MM.YY')
            WHEN ps."Date" LIKE '%-%' THEN to_date(ps."Date", 'MM-DD-YY')
            ELSE NULL 
        END, 
        'MM.YYYY'
    ) AS "Date",
    ps."Category" AS "Category",
    SUM(ps."Amount") AS "Total",
    SUM(ps."Amount" - (pc.production_cost + pc.delivery_cost)) AS "Profit"
FROM product_sales ps 
INNER JOIN product_cost pc ON ps."Category" = pc.category  
--Умови роботи з базою--
WHERE ps."Status" IN ('Shipped - Delivered to Buyer', 'Shipped')
  AND ps."Amount" IS NOT NULL 
  AND ps."Category" LIKE 'Set'
GROUP BY ps."Category", "Date"
ORDER BY "Date" ASC;
