<a id="markdown-проектная работа" name="шаблон-проектная работа"></a>
# Импорт данных БУ в систему управленческого финансового учета

## Описание
Решение предназначено для импорта данных регламентированного учета в консолидированную систему управленческого финансового учета для последующей трансляции в фактические данные БДР и БДДС. Каждый первичный документ, формирующий проводки БУ, выгружается в виде ручной операции с набором движений. Для сериализации используется механизм Enterprise Data. Обмен выполняется с использованием Apache Kafka.

## Используемые конфигурации
- Система регламентированного учета - любая типовая конфигурация, имеющая в своем составе регистр бухгалтерии "Хозрасчетный" и поддерживающая обмен через универсальный формат:
    - Бухгалтерия предприятия, редакция 3
    - ERP:Управление предприятием, редакция 2
    - Комплексная автоматизация и др.
- Система управленческого финансового учета:
    - БИТ.Финанс + любая из поддерживаемых типовых конфигураций
 
![Image alt](https://github.com/alex15650/OtusProject1C/blob/main/docs/Architecture.jpg)
