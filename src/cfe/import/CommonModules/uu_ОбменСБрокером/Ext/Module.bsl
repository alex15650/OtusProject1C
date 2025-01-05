﻿
#Область ПрограммныйИнтерфейс

Процедура ВыполнитьПолучениеСообщений() Экспорт
	
	ОбщегоНазначения.ПриНачалеВыполненияРегламентногоЗадания(Метаданные.РегламентныеЗадания.uu_ПолучениеСообщенийБрокера);
	
	МаксДлительность = Константы.uu_МаксДлительностьЧтенияСообщений.Получить();
	
	Если Не ЗначениеЗаполнено(МаксДлительность) Тогда
		МаксДлительность = 3600;
	КонецЕсли;

	Consumer = Неопределено;
	
	РезультатПодключения = ВыполнитьПодключениеВнешнейКомпоненты();
	
	Если Не РезультатПодключения.Успешно Тогда
		ЗаписьЖурналаРегистрации("ОбменСБрокеромKafka.ПолучениеСообщений", УровеньЖурналаРегистрации.Ошибка, , , СтрШаблон("Не удалось подключить внешнюю компоненту по причине: %1", РезультатПодключения.ОписаниеОшибки));
		Возврат;
	КонецЕсли;
	
	Попытка	 
		Consumer = Новый("AddIn.librdkafka.KafkaConsumer");
	Исключение
		ЗаписьЖурналаРегистрации("ОбменСБрокеромKafka.ПолучениеСообщений", УровеньЖурналаРегистрации.Ошибка, , , ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
		Возврат;
	КонецПопытки;
	
	Consumer.SetGlobalConf("message.max.bytes", "10000");
	Consumer.SetGlobalConf("socket.timeout.ms", "5000");
	Consumer.SetGlobalConf("enable.auto.commit", "false");
	Consumer.SetGlobalConf("auto.commit.interval.ms", "0");
	
	Consumer.SetTopicConf("auto.offset.reset", "smallest");
	Consumer.SetTopicConf("compression.codec", "lz4");
	
	РезультатИнициализации = Consumer.Инициализация(Константы.uu_KafkaBootstrapServer.Получить(), "BaseUpr"); 
	
	Если РезультатИнициализации <> Истина Тогда
		ЗаписьЖурналаРегистрации("ОбменСБрокеромKafka.ПолучениеСообщений", УровеньЖурналаРегистрации.Ошибка, , , СтрШаблон("Не удалось инициализировать консюмер по причине: %1", Consumer.ErrorDescription));
		Consumer = Неопределено;
		Возврат;
	КонецЕсли; 
	
	Результат = Consumer.AddTopicToSubscribeList("Operations");
	
	Если Результат <> Истина Тогда
		ЗаписьЖурналаРегистрации("ОбменСБрокеромKafka.ПолучениеСообщений", УровеньЖурналаРегистрации.Ошибка, , , СтрШаблон("Не удалось добавить топик в список подписок по причине: %1", Consumer.ErrorDescription));
		Consumer = Неопределено;
		Возврат;
	КонецЕсли;
	
	Результат = Consumer.Subscribe();
	
	Если Результат <> Истина Тогда
		ЗаписьЖурналаРегистрации("ОбменСБрокеромKafka.ПолучениеСообщений", УровеньЖурналаРегистрации.Ошибка, , , СтрШаблон("Не удалось подписаться на топик по причине: %1", Consumer.ErrorDescription));
		Consumer = Неопределено;
		Возврат;
	КонецЕсли;
	
	Consumer.EscapeMessageValue 	  = Истина;
	Consumer.EscapeMessageKey 		  = Истина;
	Consumer.EscapeMessageHeaderKey   = Истина;
	Consumer.EscapeMessageHeaderValue = Истина;
	
	МоментНачала = ТекущаяУниверсальнаяДатаВМиллисекундах();
	
	Пока Истина Цикл
		
		ВремяНачала = ОценкаПроизводительности.НачатьЗамерВремени();
		
		Результат = Consumer.ConsumePool(3000, 1000, 10);
		
		Таймаут = (Consumer.ErrorDescription = "Local: Timed out") Или (Consumer.ErrorDescription = "Timeout: Local: Timed out")
			Или (Consumer.ErrorDescription = "Local queue is full");
		Успешно = (Таймаут Или Результат = 1) И Не Consumer.FatalError;
		
		Если Не Успешно Тогда
			ЗаписьЖурналаРегистрации("ОбменСБрокеромKafka.ПолучениеСообщений", УровеньЖурналаРегистрации.Ошибка, , , СтрШаблон("Не удалось получить сообщения из топика по причине: %1", Consumer.ErrorDescription));
			Прервать;
		КонецЕсли;
		
		Сообщения = Consumer.ReceiveJSONMessages(Ложь);
		
		Если Сообщения = Неопределено Тогда
			ЗаписьЖурналаРегистрации("ОбменСБрокеромKafka.ПолучениеСообщений", УровеньЖурналаРегистрации.Ошибка, , , СтрШаблон("Не удалось получить сообщения из пула по причине: %1", Consumer.ErrorDescription));
			Прервать;
		КонецЕсли;	
		
		Результат = Consumer.ClearMessagePool();
		
		Если Результат <> Истина Тогда
			ЗаписьЖурналаРегистрации("ОбменСБрокеромKafka.ПолучениеСообщений", УровеньЖурналаРегистрации.Ошибка, , , СтрШаблон("Не удалось очистить пул сообщений по причине: %1", Consumer.ErrorDescription));
			Прервать;
		КонецЕсли; 
		
		Результат = JSONВСтруктуруДанных(Сообщения);
		
		Если Не Результат.Успешно Тогда
			ЗаписьЖурналаРегистрации("ОбменСБрокеромKafka.ПолучениеСообщений", УровеньЖурналаРегистрации.Ошибка, , , СтрШаблон("Не удалось обработать сообщения JSON по причине: %1", Результат.ОписаниеОшибки));
			Прервать;
		КонецЕсли;
		
		Если Результат.Данные.Количество() > 0 Тогда
			
			Успешно = Consumer.Commit();
			
			Если Успешно <> Истина Тогда 
				ЗаписьЖурналаРегистрации("ОбменСБрокеромKafka.ПолучениеСообщений", УровеньЖурналаРегистрации.Ошибка, , , СтрШаблон("Не удалось подтвердить получение сообщений по причине: %1", Consumer.ErrorDescription));
				Прервать;
			КонецЕсли;
			
			ЗаписатьПолученныеСообщения(Результат.Данные);
			
			ОценкаПроизводительности.ЗакончитьЗамерВремени("ПолучениеСообщенийИзТопикаKafka", ВремяНачала, Результат.Данные.Количество());
			
		КонецЕсли;
		
		МоментОкончания = ТекущаяУниверсальнаяДатаВМиллисекундах();
		
		Разница = (МоментОкончания - МоментНачала) / 1000;
		
		Если Разница >= МаксДлительность Тогда
			Прервать;
		КонецЕсли;
		
	КонецЦикла; 
	
	Consumer.Unassign();
	Consumer.Unsubscribe();
	
	Consumer = Неопределено;
	
КонецПроцедуры

Процедура ВыполнитьОбработкуСообщений() Экспорт
	
	ОбщегоНазначения.ПриНачалеВыполненияРегламентногоЗадания(Метаданные.РегламентныеЗадания.uu_ОбработкаСообщенийБрокера);
	
	ПериодПовтораОбработкиСообщений = Константы.uu_ПериодПовтораОбработкиСообщений.Получить();
	
	Если Не ЗначениеЗаполнено(ПериодПовтораОбработкиСообщений) Тогда
		ПериодПовтораОбработкиСообщений = 900;
	КонецЕсли;
	
	КомпонентыОбмена = КомпонентыОбмена("Получение");
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ ПЕРВЫЕ 1000
	|	uu_ВходящиеСообщения.Ссылка КАК Ссылка,
	|	uu_ВходящиеСообщения.Сообщение КАК Сообщение
	|ИЗ
	|	Справочник.uu_ВходящиеСообщения КАК uu_ВходящиеСообщения
	|ГДЕ
	|	uu_ВходящиеСообщения.Объект = НЕОПРЕДЕЛЕНО
	|	И uu_ВходящиеСообщения.ПопытокОбработки < 10
	|	И uu_ВходящиеСообщения.ДатаСледующейОбработки <= &ТекущаяДата
	|
	|УПОРЯДОЧИТЬ ПО
	|	uu_ВходящиеСообщения.ДатаПолучения,
	|	uu_ВходящиеСообщения.ДатаСледующейОбработки";
	Запрос.УстановитьПараметр("ТекущаяДата", ТекущаяДатаСеанса());
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Пока Выборка.Следующий() Цикл
		
		ВремяНачала = ОценкаПроизводительности.НачатьЗамерВремени();
		
		Сообщение = Выборка.Ссылка.ПолучитьОбъект();
		
		Результат = ОбработатьСообщениеEnterpriseData(Выборка.Сообщение, КомпонентыОбмена);	
		
		Если Результат.ЕстьОшибки Тогда
			Сообщение.ОшибкиОбработки = Результат.ТекстОшибки;
			Сообщение.ПопытокОбработки = Сообщение.ПопытокОбработки + 1;
			Сообщение.ДатаСледующейОбработки = ?(Сообщение.ПопытокОбработки = 10, Дата(3999, 12, 31), ТекущаяДатаСеанса() + ПериодПовтораОбработкиСообщений);
		ИначеЕсли Результат.ЗагруженныеОбъекты.Количество() > 0 Тогда
			Сообщение.ОшибкиОбработки = "";
			Сообщение.ПопытокОбработки = Сообщение.ПопытокОбработки + 1;
			Сообщение.Объект = Результат.ЗагруженныеОбъекты[0];
			Сообщение.ДатаСледующейОбработки = Дата(1, 1, 1);
		КонецЕсли;
		
		Сообщение.Записать();
		
		Если Не Результат.ЕстьОшибки
			И ЗначениеЗаполнено(Сообщение.Объект) Тогда
			ОценкаПроизводительности.ЗакончитьЗамерВремени("ОбработкаСообщенияKafka", ВремяНачала, 1);
		КонецЕсли;
		
		КомпонентыОбмена.СтрокаСообщенияОбОшибке = "";
		КомпонентыОбмена.ФлагОшибки = Ложь;
		КомпонентыОбмена.ЗагруженныеОбъекты.Очистить();
		КомпонентыОбмена.Удалить("ФайлОбмена");
		
		КомпонентыОбмена.ЗагруженныеОбъекты.Колонки.Удалить("Очередность");
		КомпонентыОбмена.ЗагруженныеОбъекты.Колонки.Удалить("ДатаДляСортировкиДокументов");
		КомпонентыОбмена.ЗагруженныеОбъекты.Колонки.Удалить("НомерИсправленияДляСортировкиКорректировок");
		
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция КомпонентыОбмена(НаправлениеОбмена) 
	
	КомпонентыОбмена     = ОбменДаннымиXDTOСервер.ИнициализироватьКомпонентыОбмена(НаправлениеОбмена);
	ТекВерсияФормата     = "1.16";
	ТекРасширениеФормата = "http://v8.1c.ru/edi/edi_stnd/ED_UU/1.0";
	
	КомпонентыОбмена.ЭтоОбменЧерезПланОбмена = Ложь;
	КомпонентыОбмена.КлючСообщенияЖурналаРегистрации = НСтр("ru = 'Импорт данных из системы регл. учета'", ОбщегоНазначения.КодОсновногоЯзыка());
	КомпонентыОбмена.ВерсияФорматаОбмена = ТекВерсияФормата;
	КомпонентыОбмена.XMLСхема = "http://v8.1c.ru/edi/edi_stnd/EnterpriseData/" + ТекВерсияФормата;
	
	ОбменДаннымиXDTOСервер.ВключитьПространствоИмен(КомпонентыОбмена, ТекРасширениеФормата, "ext");

	ВерсииФорматаОбмена = Новый Соответствие;
	
	ОбменДаннымиПереопределяемый.ПриПолученииДоступныхВерсийФормата(ВерсииФорматаОбмена);
	
	КомпонентыОбмена.МенеджерОбмена = ВерсииФорматаОбмена.Получить(ТекВерсияФормата);
	
	Если КомпонентыОбмена.МенеджерОбмена = Неопределено Тогда
		ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru = 'Не поддерживается версия формата обмена: <%1>.'"), ТекВерсияФормата);
	КонецЕсли;
	
	ОбменДаннымиXDTOСервер.ИнициализироватьТаблицыПравилОбмена(КомпонентыОбмена);	
	ОбменДаннымиXDTOСервер.ПослеИнициализацииКомпонентыОбмена(КомпонентыОбмена);
	
	Возврат КомпонентыОбмена;
	
КонецФункции

Функция ВыполнитьПодключениеВнешнейКомпоненты()	
	
	Результат = Новый Структура;
	Результат.Вставить("Успешно", Ложь);
	Результат.Вставить("ОписаниеОшибки", "");     
	
	СистемнаяИнформация = Новый СистемнаяИнформация();
	
	Если СистемнаяИнформация.ТипПлатформы = ТипПлатформы.Windows_x86 Тогда	
		МакетКомпоненты = ПолучитьОбщийМакет("librdkafka_win32");
	ИначеЕсли СистемнаяИнформация.ТипПлатформы = ТипПлатформы.Windows_x86_64 Тогда
		МакетКомпоненты = ПолучитьОбщийМакет("librdkafka_win64");
	ИначеЕсли СистемнаяИнформация.ТипПлатформы = ТипПлатформы.Linux_x86 Тогда
		МакетКомпоненты = ПолучитьОбщийМакет("librdkafka_linux32");	
	ИначеЕсли СистемнаяИнформация.ТипПлатформы = ТипПлатформы.Linux_x86_64 Тогда
		МакетКомпоненты = ПолучитьОбщийМакет("librdkafka_linux64");		
	Иначе
		Результат.ОписаниеОшибки = "Не поддерживаемая архитектура платформы";
		Возврат Результат;
	КонецЕсли;
	
	Попытка
		РезультатПодключенияВнешнейКомпоненты = ПодключитьВнешнююКомпоненту(ПоместитьВоВременноеХранилище(МакетКомпоненты), "librdkafka", ТипВнешнейКомпоненты.Native);
		Если Не РезультатПодключенияВнешнейКомпоненты Тогда
			Результат.ОписаниеОшибки = "Ошибка подключения внешней компоненты";
			Возврат Результат;
		КонецЕсли;
	Исключение
		Результат.ОписаниеОшибки = КраткоеПредставлениеОшибки(ИнформацияОбОшибке());
		Возврат Результат;
	КонецПопытки;
		
	Результат.Успешно = Истина;
	
	Возврат Результат;
	
КонецФункции

Функция JSONВСтруктуруДанных(СтрокаJSON)
		
	Результат = Новый Структура;
	
	Результат.Вставить("Успешно",        Ложь);
	Результат.Вставить("Данные",         Неопределено);
	Результат.Вставить("ОписаниеОшибки", "");
	
	Чтение = Новый ЧтениеJSON;
	Чтение.УстановитьСтроку(СтрокаJSON);
	
	Попытка
		Данные = ПрочитатьJSON(Чтение, Ложь);
		
		Если ТипЗнч(Данные) = Тип("Структура") Тогда
			Результат.Данные = Новый Массив();	
			Результат.Данные.Добавить(Данные);
		ИначеЕсли ТипЗнч(Данные) = Тип("Массив") Тогда
			Результат.Данные = Данные;				
		Иначе
			ВызватьИсключение "Неверный тип данных!";
		КонецЕсли;
		
		Результат.Успешно = Истина;
	Исключение
		Результат.ОписаниеОшибки = КраткоеПредставлениеОшибки(ИнформацияОбОшибке());
	КонецПопытки;	
	
	Чтение.Закрыть();
	
	Возврат Результат;
	
КонецФункции

Процедура ЗаписатьПолученныеСообщения(МассивДанных)
	
	Для Каждого СтруктураДанных Из МассивДанных Цикл
		
		ВходящееСообщение = Справочники.uu_ВходящиеСообщения.СоздатьЭлемент();
		
		ВходящееСообщение.Код 	    	= СтруктураДанных.Key;
		ВходящееСообщение.Топик 		= СтруктураДанных.Topic;
		ВходящееСообщение.Партиция  	= СтруктураДанных.Partition;
		ВходящееСообщение.Смещение  	= СтруктураДанных.Offset;
		ВходящееСообщение.Сообщение 	= СтруктураДанных.Value;
		ВходящееСообщение.ДатаПолучения = ТекущаяДатаСеанса();
		
		ВходящееСообщение.Записать();
		
	КонецЦикла;
	
КонецПроцедуры

Функция ОбработатьСообщениеEnterpriseData(ТекстСообщения, КомпонентыОбмена)
	
	ЧтениеXML = Новый ЧтениеXML;
	ЧтениеXML.УстановитьСтроку(ТекстСообщения);
	
	РезультатЗагрузки = Новый Структура;
	РезультатЗагрузки.Вставить("ЕстьОшибки", Ложь);
	РезультатЗагрузки.Вставить("ТекстОшибки", "");
	РезультатЗагрузки.Вставить("ЗагруженныеОбъекты", Новый Массив);
	
	ЧтениеXML.Прочитать(); // Message
	ЧтениеXML.Прочитать(); // Header
	
	ЗаголовокСообщенияXDTO = ФабрикаXDTO.ПрочитатьXML(ЧтениеXML, ФабрикаXDTO.Тип("http://www.1c.ru/SSL/Exchange/Message", "Header"));
	
	Если ЧтениеXML.ТипУзла <> ТипУзлаXML.НачалоЭлемента
		Или ЧтениеXML.ЛокальноеИмя <> "Body" Тогда
		
		РезультатЗагрузки.ЕстьОшибки = Истина;
		РезультатЗагрузки.ТекстОшибки = НСтр("ru = 'Ошибка чтения сообщения загрузки. Неверный формат сообщения.'");
		
		Возврат РезультатЗагрузки;
	КонецЕсли;
	
	ЧтениеXML.Прочитать(); // Body
	КомпонентыОбмена.Вставить("ФайлОбмена", ЧтениеXML);
	
	УстановитьПривилегированныйРежим(Истина); 
	
	ОбменДаннымиСлужебный.ОтключитьОбновлениеКлючейДоступа(Истина);
	
	Попытка
		ОбменДаннымиXDTOСервер.ПроизвестиЧтениеДанных(КомпонентыОбмена);
		ОбменДаннымиСлужебный.ОтключитьОбновлениеКлючейДоступа(Ложь);
	Исключение
		ОбменДаннымиСлужебный.ОтключитьОбновлениеКлючейДоступа(Ложь);
		ВызватьИсключение;
	КонецПопытки; 
	
	УстановитьПривилегированныйРежим(Ложь);
	
	Если КомпонентыОбмена.ФлагОшибки Тогда
		РезультатЗагрузки.ЕстьОшибки = Истина;
		РезультатЗагрузки.ТекстОшибки = КомпонентыОбмена.СтрокаСообщенияОбОшибке;
	КонецЕсли;
	
	РезультатЗагрузки.ЗагруженныеОбъекты = КомпонентыОбмена.ЗагруженныеОбъекты.ВыгрузитьКолонку("СсылкаНаОбъект"); 
	
	Возврат РезультатЗагрузки;
	
КонецФункции

#КонецОбласти