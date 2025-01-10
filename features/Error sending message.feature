﻿#language: ru

@tree

Функционал: Проверка фиксации ошибки отправки сообщения в брокер.

Как пользователь я хочу:
создать первичный документ и убедиться, что будет создана операция к отражению в упр. учете и добавлена в очередь обмена, и в случае недоступности брокера
будет зафиксирована ошибка отправки, чтобы потом иметь возможность её устранить и отправить сообщение 

Контекст:
	Дано Я запускаю сценарий открытия TestClient или подключаю уже существующий

Сценарий: Создание документа "Списание товаров", проверка формирования XML-сообщения и фиксации ошибки отправки

	* Создание и проведение первичного документа
		И В командном интерфейсе я выбираю "Склад" "Списание товаров, материалов"
		Тогда открылось окно "Списание товаров, материалов"
		И я нажимаю на кнопку с именем 'ФормаСоздать'
		Тогда открылось окно "Списание товаров, материалов (создание)"
		И из выпадающего списка с именем 'Склад' я выбираю точное значение "РЦ"
		И из выпадающего списка с именем 'ПодразделениеОрганизации' я выбираю точное значение "Основное подразделение"
		И в таблице 'Товары' я нажимаю на кнопку с именем 'ТоварыДобавить'
		И в таблице 'Товары' из выпадающего списка с именем 'ТоварыНоменклатура' я выбираю точное значение "Бумага"
		И в таблице 'Товары' в поле с именем 'ТоварыКоличество' я ввожу текст "1,000"
		И в таблице 'Товары' из выпадающего списка с именем 'ТоварыСчетУчета' я выбираю точное значение "10.06"
		И в таблице 'Товары' я завершаю редактирование строки
		И я нажимаю на кнопку с именем 'ФормаПровестиИЗакрыть'
		И я жду закрытия окна "Списание товаров, материалов (создание) *" в течение 5 секунд

	* Проверка формирования XML-сообщения
		И В командном интерфейсе я выбираю "Экспорт данных БУ" "Очередь сообщений"
		Тогда открылось окно "Очередь сообщений"
		Тогда в таблице "Список" количество строк "равно" 1
		И в таблице "Список" я активизирую поле "Текст сообщения"
		И я жду, что в таблице текущее поле будет заполнено в течение 15 секунд.

	* Проверка фиксации ошибки отправки
		Тогда в таблице "Список" количество строк "равно" 1
		И в таблице "Список" у поля "Ошибки отправки" я жду значения "Local: Message timed out" в течение 30 секунд
				
						