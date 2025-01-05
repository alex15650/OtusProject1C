﻿
#Область ПрограммныйИнтерфейс

Процедура ВыполнитьСериализациюСообщений() Экспорт
	
	ОбщегоНазначения.ПриНачалеВыполненияРегламентногоЗадания(Метаданные.РегламентныеЗадания.uu_СериализацияСообщений);
	
	УстановитьПривилегированныйРежим(Истина);
	
	КомпонентыОбмена = КомпонентыОбмена("Отправка");
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	uu_ОчередьСообщений.Топик КАК Топик,
	|	uu_ОчередьСообщений.Объект КАК Объект,
	|	uu_ОчередьСообщений.ДатаДобавления КАК ДатаДобавления
	|ИЗ
	|	РегистрСведений.uu_ОчередьСообщений КАК uu_ОчередьСообщений
	|ГДЕ
	|	(ВЫРАЗИТЬ(uu_ОчередьСообщений.ТекстСообщения КАК СТРОКА(50))) = """"
	|
	|УПОРЯДОЧИТЬ ПО
	|	ДатаДобавления";
		
	Выборка = Запрос.Выполнить().Выбрать(); 
	
	Пока Выборка.Следующий() Цикл
		
		ВремяНачала = ОценкаПроизводительности.НачатьЗамерВремени();
		
		Запись = РегистрыСведений.uu_ОчередьСообщений.СоздатьМенеджерЗаписи();
		ЗаполнитьЗначенияСвойств(Запись, Выборка);
		
		Запись.Прочитать();
		
		Если Не Запись.Выбран() Тогда
			Продолжить;
		КонецЕсли;
		
		Попытка
			КомпонентыОбмена.МенеджерОбмена.ПередКонвертацией(КомпонентыОбмена);
		Исключение
			ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru = 'Событие: %1.
				|Обработчик: ПередКонвертацией.
				|
				|Ошибка выполнения обработчика.
				|%2.'"),
				КомпонентыОбмена.НаправлениеОбмена,
				ОбработкаОшибок.ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
			ОбменДаннымиXDTOСервер.ЗаписатьВПротоколВыполнения(КомпонентыОбмена, ТекстОшибки);
			Запись.ОшибкиСериализации = ТекстОшибки;
			Запись.Записать();
			Продолжить;
		КонецПопытки; 
		
		Попытка
			
			// Открываем файл обмена.
			ОбменДаннымиXDTOСервер.ОткрытьФайлВыгрузки(КомпонентыОбмена);
			
			МетаданныеСсылкиВыгрузки = Выборка.Объект.Метаданные();
			
			ПравилоОбработки = КомпонентыОбмена.ПравилаОбработкиДанных.Найти(МетаданныеСсылкиВыгрузки, "ОбъектВыборкиМетаданные");
			
			Если ПравилоОбработки = Неопределено Тогда
				Запись.ОшибкиСериализации = "Не найдено правило обработки данных";
				Запись.Записать();
				Продолжить;
			КонецЕсли;
			
			Если ОбщегоНазначения.ЭтоОбъектСсылочногоТипа(МетаданныеСсылкиВыгрузки) Тогда
				ОбъектДляВыгрузки = Выборка.Объект.ПолучитьОбъект(); 
				ОбменДаннымиXDTOСервер.ВыгрузкаОбъектаВыборки(КомпонентыОбмена, ОбъектДляВыгрузки, ПравилоОбработки);
			КонецЕсли;
			
			Если КомпонентыОбмена.ФлагОшибки Тогда
				Запись.ОшибкиСериализации = КомпонентыОбмена.СтрокаСообщенияОбОшибке;
				Запись.Записать();
			Иначе
				
				КомпонентыОбмена.ФайлОбмена.ЗаписатьКонецЭлемента(); // Body
				КомпонентыОбмена.ФайлОбмена.ЗаписатьКонецЭлемента(); // Message
				
				Результат = КомпонентыОбмена.ФайлОбмена.Закрыть();
				
				Запись.ТекстСообщения = Результат;
				Запись.ОшибкиСериализации = "";
				Запись.Записать();
				
				ОценкаПроизводительности.ЗакончитьЗамерВремени("СериализацияXDTO." + МетаданныеСсылкиВыгрузки.ПолноеИмя(), ВремяНачала, 1);
				
			КонецЕсли;
			
		Исключение
			Запись.ОшибкиСериализации = КраткоеПредставлениеОшибки(ИнформацияОбОшибке());
			Запись.Записать();
		КонецПопытки;
		
		КомпонентыОбмена.СтрокаСообщенияОбОшибке = "";
		КомпонентыОбмена.ФлагОшибки = Ложь;
		КомпонентыОбмена.Удалить("ФайлОбмена");
		
	КонецЦикла;
	
	УстановитьПривилегированныйРежим(Ложь);		
	
КонецПроцедуры

Процедура ВыполнитьОтправкуСообщений() Экспорт 
	
	ОбщегоНазначения.ПриНачалеВыполненияРегламентногоЗадания(Метаданные.РегламентныеЗадания.uu_ОтправкаСообщенийВБрокер);

	Producer = Неопределено;
	
	РезультатПодключения = ВыполнитьПодключениеВнешнейКомпоненты();
	
	Если Не РезультатПодключения.Успешно Тогда
		ЗаписьЖурналаРегистрации("ОбменСБрокеромKafka.ОтправкаСообщений", УровеньЖурналаРегистрации.Ошибка, , , СтрШаблон("Не удалось подключить компоненту Kafka по причине: %1", РезультатПодключения.ОписаниеОшибки));
		Возврат;
	КонецЕсли;
	
	Попытка	 
		Producer = Новый("AddIn.librdkafka.KafkaProducer");
	Исключение
		ЗаписьЖурналаРегистрации("ОбменСБрокеромKafka.ОтправкаСообщений", УровеньЖурналаРегистрации.Ошибка, , , ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
		Возврат;
	КонецПопытки;
	
	Producer.SetGlobalConf("queue.buffering.max.messages", "1000000");
	Producer.SetGlobalConf("socket.timeout.ms", "5000");
	Producer.SetGlobalConf("delivery.report.only.error", "false");
	
	Producer.SetTopicConf("message.timeout.ms", "5000");
	Producer.SetTopicConf("compression.codec", "lz4");
	Producer.SetTopicConf("request.required.acks", "-1");
	
	РезультатИнициализации = Producer.Initialize(Константы.uu_KafkaBootstrapServer.Получить(), "Operations", -1); 
	
	Если РезультатИнициализации <> Истина Тогда
		ЗаписьЖурналаРегистрации("ОбменСБрокеромKafka.ОтправкаСообщений", УровеньЖурналаРегистрации.Ошибка, , , Producer.ErrorDescription);
		Producer = Неопределено;
		Возврат;
	КонецЕсли;
	
	СообщениеОбОшибке = "";
	
	Пока Истина Цикл
		
		ДанныеНаЗапись = Новый Массив;
		КлючиСообщений = Новый Массив;
		СообщениеОбОшибке = "";
		
		Запрос = Новый Запрос;
		Запрос.Текст =
		"ВЫБРАТЬ ПЕРВЫЕ 1000
		|	uu_ОчередьСообщений.Топик КАК Топик,
		|	uu_ОчередьСообщений.Объект КАК Объект,
		|	uu_ОчередьСообщений.ДатаДобавления КАК ДатаДобавления,
		|	uu_ОчередьСообщений.ТекстСообщения КАК ТекстСообщения,
		|	uu_ОчередьСообщений.ДатаСледующейОтправки КАК ДатаСледующейОтправки
		|ИЗ
		|	РегистрСведений.uu_ОчередьСообщений КАК uu_ОчередьСообщений
		|ГДЕ
		|	(ВЫРАЗИТЬ(uu_ОчередьСообщений.ТекстСообщения КАК СТРОКА(50))) <> """"
		|	И uu_ОчередьСообщений.ПопытокОтправки < 10
		|	И uu_ОчередьСообщений.ДатаСледующейОтправки <= &ТекущаяДата
		|
		|УПОРЯДОЧИТЬ ПО
		|	ДатаДобавления,
		|	ДатаСледующейОтправки";
		Запрос.УстановитьПараметр("ТекущаяДата", ТекущаяДатаСеанса());
		РезультатЗапроса = Запрос.Выполнить();
		
		Если РезультатЗапроса.Пустой() Тогда
			Прервать;
		КонецЕсли;
		
		ВыборкаСообщения = РезультатЗапроса.Выбрать();
		
		ВремяНачала = ОценкаПроизводительности.НачатьЗамерВремени();
		
		Пока ВыборкаСообщения.Следующий() Цикл	
			Заголовки = Новый Массив;
			КлючСообщения = XMLСтрока(Новый УникальныйИдентификатор);
			ДанныеНаЗапись.Добавить(Новый Структура("Key,Value,Headers", КлючСообщения, ВыборкаСообщения.ТекстСообщения, Заголовки));			
			КлючиСообщений.Добавить(Новый Структура("Ключ,Топик,Объект,ДатаДобавления", КлючСообщения, ВыборкаСообщения.Топик, ВыборкаСообщения.Объект, ВыборкаСообщения.ДатаДобавления));
		КонецЦикла; 
		
		РезультатПреобразования = СтруктураДанныхВJSON(ДанныеНаЗапись);
		
		Если Не РезультатПреобразования.Успешно Тогда
			СообщениеОбОшибке = СтрШаблон("Не удалось преобразовать сообщения в JSON по причине: %1", РезультатПреобразования.ОписаниеОшибки);
			ЗаписьЖурналаРегистрации("ОбменСБрокеромKafka.ОтправкаСообщений", УровеньЖурналаРегистрации.Ошибка, , , СообщениеОбОшибке);	 
			ОбработатьОтправляемыеСообщения(КлючиСообщений, СообщениеОбОшибке);
			Прервать;
		КонецЕсли;
		
		Результат = Producer.SetJSONMessageList(РезультатПреобразования.Данные);
		
		Если Результат <> Истина Тогда
			СообщениеОбОшибке = СтрШаблон("Не удалось поместить сообщения в пул отправки по причине: %1", Producer.ErrorDescription);
			ЗаписьЖурналаРегистрации("ОбменСБрокеромKafka.ОтправкаСообщений", УровеньЖурналаРегистрации.Ошибка, , , СообщениеОбОшибке); 
			ОбработатьОтправляемыеСообщения(КлючиСообщений, СообщениеОбОшибке);
			Прервать;
		КонецЕсли;
		
		РезультатОтправки = Producer.Produce();
		
		Если РезультатОтправки <> Истина Тогда
			СообщениеОбОшибке = СтрШаблон("Не удалось отправить сообщения в топик по причине: %1", Producer.ErrorDescription);
			ЗаписьЖурналаРегистрации("ОбменСБрокеромKafka.ОтправкаСообщений", УровеньЖурналаРегистрации.Ошибка, , , СообщениеОбОшибке);	
			ОбработатьОтправляемыеСообщения(КлючиСообщений, СообщениеОбОшибке, Producer.GetJSONDeliveryReport());
			Прервать;
		КонецЕсли;
		
		ОбработатьОтправляемыеСообщения(КлючиСообщений, СообщениеОбОшибке, Producer.GetJSONDeliveryReport());
		
		Если Producer.IsDelivered() = Истина Тогда
			ОценкаПроизводительности.ЗакончитьЗамерВремени("ОтправкаСообщенийВТопикKafka", ВремяНачала, ВыборкаСообщения.Количество(), СтрШаблон("Количество сообщений: %1", ВыборкаСообщения.Количество()));
		КонецЕсли;
		
	КонецЦикла;
	
	Producer = Неопределено;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция КомпонентыОбмена(НаправлениеОбмена) 
	
	КомпонентыОбмена     = ОбменДаннымиXDTOСервер.ИнициализироватьКомпонентыОбмена(НаправлениеОбмена);
	ТекВерсияФормата     = "1.16";
	ТекРасширениеФормата = "http://v8.1c.ru/edi/edi_stnd/ED_UU/1.0";
	
	КомпонентыОбмена.ЭтоОбменЧерезПланОбмена = Ложь;
	КомпонентыОбмена.КлючСообщенияЖурналаРегистрации = НСтр("ru = 'Экспорт данных в систему упр. учета'", ОбщегоНазначения.КодОсновногоЯзыка());
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

Функция СтруктураДанныхВJSON(Данные)
	
	Результат = Новый Структура;
	
	Результат.Вставить("Успешно",        Ложь);
	Результат.Вставить("Данные", 	    "");
	Результат.Вставить("ОписаниеОшибки", "");
	
	ЗаписьJSON                = Новый ЗаписьJSON();
	НастройкиСериализацииJSON = Новый НастройкиСериализацииJSON();
	
	ЗаписьJSON.УстановитьСтроку();
	
	НастройкиСериализацииJSON.ВариантЗаписиДаты      = ВариантЗаписиДатыJSON.ЛокальнаяДата;
	НастройкиСериализацииJSON.ФорматСериализацииДаты = ФорматДатыJSON.ISO;
	
	Попытка
		ЗаписатьJSON(ЗаписьJSON, Данные, НастройкиСериализацииJSON);
		
		Результат.Данные  = ЗаписьJSON.Закрыть();
		Результат.Успешно = Истина;
	Исключение
		Результат.ОписаниеОшибки = КраткоеПредставлениеОшибки(ИнформацияОбОшибке());	
	КонецПопытки;
	
	Возврат Результат;
	
КонецФункции

Процедура ОбработатьОтправляемыеСообщения(МассивСообщений, ОшибкаОтправки = Неопределено, ОтчетОДоставке = Неопределено)
	
	ПериодПовтораОтправкиСообщений = Константы.uu_ПериодПовтораОтправкиСообщений.Получить();
	
	Если Не ЗначениеЗаполнено(ПериодПовтораОтправкиСообщений) Тогда
		ПериодПовтораОтправкиСообщений = 900;
	КонецЕсли;
	
	РезультатыОтправки = Новый Соответствие;

	// Отчет о доставке по каждому сообщению
	Если ЗначениеЗаполнено(ОтчетОДоставке) Тогда
		
		Чтение = Новый ЧтениеJSON;
		Чтение.УстановитьСтроку(ОтчетОДоставке); 
		
		Данные = ПрочитатьJSON(Чтение, Ложь, , ФорматДатыJSON.JavaScript);
		
		Чтение.Закрыть();
		
		Для Каждого Результат Из Данные Цикл
			РезультатыОтправки.Вставить(Результат.Key, Результат);
		КонецЦикла;
		
	КонецЕсли;
	
	// Обработка сообщений
	Для Каждого КлючСообщения Из МассивСообщений Цикл
		
		Ключ = КлючСообщения.Ключ;
		РезультатОтправки = РезультатыОтправки[Ключ];
		
		НачатьТранзакцию();
		
		Попытка
			
			// Запись очереди
			Запись = РегистрыСведений.uu_ОчередьСообщений.СоздатьМенеджерЗаписи();
			ЗаполнитьЗначенияСвойств(Запись, КлючСообщения);
			
			Запись.Прочитать();
			
			Если Запись.Выбран() Тогда
				
				Если ЗначениеЗаполнено(ОшибкаОтправки) Тогда
					
					// Общая ошибка
					Запись.ОшибкиОтправки 		 = ОшибкаОтправки;
					Запись.ПопытокОтправки 		 = Запись.ПопытокОтправки + 1;
					Запись.ДатаСледующейОтправки = ?(Запись.ПопытокОтправки = 10, Дата(3999, 12, 31), ТекущаяДатаСеанса() + ПериодПовтораОтправкиСообщений); 
					
					Если ТипЗнч(РезультатОтправки) = Тип("Структура")
						И РезультатОтправки.Свойство("Error")
						И РезультатОтправки.Error <> "Success" Тогда
						Запись.ОшибкиОтправки = Запись.ОшибкиОтправки + Символы.ПС + РезультатОтправки.Error;
					КонецЕсли;
					
					Запись.Записать();
					
				ИначеЕсли ТипЗнч(РезультатОтправки) = Тип("Структура")
					И РезультатОтправки.Свойство("Error") Тогда
					
					Если РезультатОтправки.Error <> "Success" Тогда
						
						// Ошибка
						Запись.ОшибкиОтправки 		 = РезультатОтправки.Error;
						Запись.ПопытокОтправки 		 = Запись.ПопытокОтправки + 1;
						Запись.ДатаСледующейОтправки = ?(Запись.ПопытокОтправки = 10, Дата(3999, 12, 31), ТекущаяДатаСеанса() + ПериодПовтораОтправкиСообщений);
						Запись.Записать();
						
					Иначе
						
						// Успешная отправка
						
						// Исходящее сообщение
						ИсходящееСообщение 				  = Справочники.uu_ИсходящиеСообщения.СоздатьЭлемент();
						ИсходящееСообщение.Код 			  = Ключ;
						ИсходящееСообщение.Топик 		  = РезультатОтправки.Topic;
						ИсходящееСообщение.Партиция 	  = РезультатОтправки.Partition;
						ИсходящееСообщение.Смещение 	  = РезультатОтправки.Offset;
						ИсходящееСообщение.Объект 		  = Запись.Объект;
						ИсходящееСообщение.ДатаОтправки   = ТекущаяДатаСеанса();
						ИсходящееСообщение.ТекстСообщения = Запись.ТекстСообщения;
						
						ИсходящееСообщение.Записать();
						
						// Удаление из очереди
						Запись.Удалить();
						
					КонецЕсли;
						
				КонецЕсли;
				
			КонецЕсли;
			
			ЗафиксироватьТранзакцию();
			
		Исключение
			ОтменитьТранзакцию();
			ЗаписьЖурналаРегистрации("ОбменСБрокеромKafka.ОтправкаСообщений", УровеньЖурналаРегистрации.Ошибка, , , СтрШаблон("При обработке сообщения по объекту %1 произошла ошибка: %2", КлючСообщения.Объект, ПодробноеПредставлениеОшибки(ИнформацияОбОшибке())));
		КонецПопытки;
		
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти