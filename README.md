<a id="markdown-проектная работа" name="шаблон-проектная работа"></a>
# Импорт данных БУ в систему управленческого финансового учета

## Описание
Решение предназначено для импорта данных регламентированного учета в систему управленческого финансового учета (БИТ.Финанс) в целях последующей трансляции в фактические данные бюджетирования. Решение также может быть использовано для консолидации данных из нескольких источников.

## Используемые конфигурации
- Система регламентированного учета - любая типовая конфигурация, имеющая в своем составе регистр бухгалтерии "Хозрасчетный" и поддерживающая обмен через универсальный формат:
    - Бухгалтерия предприятия, редакция 3
    - ERP:Управление предприятием, редакция 2
    - Комплексная автоматизация и др.
- Система управленческого финансового учета:
    - БИТ.Финанс (совместно с одной из поддерживаемых типовых конфигураций)

## Принцип работы
- При создании первичных документов автоматически создается документ-абстракция и регистрируется в очереди. Документ-абстракция позволяет избежать разработки десятков правил конвертации для типовых документов.
- Для документа-абстракции реализованы правила конвертации в документ "Операция (бух. учет)" через универсальный формат.
- Регламентное задание сериализует новые сообщения по формату Enterprise Data. Результирующее сообщение содержит набор движений исходного документа. НСИ передается в составе каждого сообщения в минимальном объеме, что достаточно для настройки трансляции.
- Сериализованные сообщения отправляются в топик Kafka регламентным заданием.
- Система-приемник получает сообщения из топика и обрабатывает их, в результате формируются документы "Операция (бух. учет)" с набором проводок.
- Используя механизм трансляции БИТ.Финанс, легко настроить переложение данных регл. учета в фактические данные бюджетирования. Таким образом, при записи операций автоматически формируется факт по БДР.

![Image alt](https://github.com/alex15650/OtusProject1C/blob/main/docs/Architecture.jpg)

## Ограничения прототипа проекта
- Для демонстрации функционала используется конфигурация "Бухгалтерия предприятия КОРП, редакция 3.0" (на поддержке), функционал БИТ.Финанс не демонстрируется.