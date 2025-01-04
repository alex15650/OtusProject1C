﻿
#Область СлужебныйПрограммныйИнтерфейс

Процедура ОбработатьСубконто(Счет, КоллекцияСубконто, ЗначениеСубконто) Экспорт
	
	Если Не ТипЗнч(ЗначениеСубконто) = Тип("Структура") Тогда
		Возврат;
	КонецЕсли;
	
	ЭтоПеречисление = ЗначениеСубконто.Свойство("ПредопределенноеЗначение");
	ЭтоСправочник 	= ЗначениеСубконто.Свойство("Код") Или ЗначениеСубконто.Свойство("Наименование");
	ЭтоДокумент 	= ЗначениеСубконто.Свойство("Номер") И ЗначениеСубконто.Свойство("Дата"); 
	
	Если ЭтоПеречисление Тогда
		
		Попытка 
			
			ЗначениеПеречисления = ПредопределенноеЗначение(ЗначениеСубконто.ПредопределенноеЗначение);	
			ВидСубконто = ПодобратьВидСубконто(Счет, ТипЗнч(ЗначениеПеречисления));
			
			Если ЗначениеЗаполнено(ВидСубконто) Тогда
				КоллекцияСубконто[ВидСубконто] = ЗначениеПеречисления;
			КонецЕсли;
			
		Исключение
		КонецПопытки;
		
	ИначеЕсли ЭтоСправочник
		И Справочники.ТипВсеСсылки().СодержитТип(Тип("СправочникСсылка." + ЗначениеСубконто.Имя)) Тогда
		
		// Справочник
		ВидСубконто = ПодобратьВидСубконто(Счет, Тип("СправочникСсылка." + ЗначениеСубконто.Имя));
		
		Если Не ЗначениеЗаполнено(ВидСубконто) Тогда
			Возврат;
		КонецЕсли;
		
		Ссылка = Справочники[ЗначениеСубконто.Имя].ПолучитьСсылку(Новый УникальныйИдентификатор(ЗначениеСубконто.ID));
		
		Если ОбщегоНазначения.СсылкаСуществует(Ссылка) Тогда
			КоллекцияСубконто[ВидСубконто] = Ссылка;	
		Иначе
			
			ОбъектНСИ = Справочники[ЗначениеСубконто.Имя].СоздатьЭлемент();
			ОбъектНСИ.УстановитьСсылкуНового(Ссылка);
			
			ЗаполнитьЗначенияСвойств(ОбъектНСИ, ЗначениеСубконто, "Код,Наименование");
			
			ОбъектНСИ.ОбменДанными.Загрузка = Истина;
			ОбъектНСИ.Записать();
			
			КоллекцияСубконто[ВидСубконто] = ОбъектНСИ.Ссылка;
			
		КонецЕсли;
		
	ИначеЕсли ЭтоДокумент Тогда
		
		// Документ
		ДокументСсылка = СсылкаНаДокумент(ЗначениеСубконто);
		
		Если ЗначениеЗаполнено(ДокументСсылка) Тогда
			
			ВидСубконто = ПодобратьВидСубконто(Счет, ТипЗнч(ДокументСсылка));
			
			Если ЗначениеЗаполнено(ВидСубконто) Тогда
				КоллекцияСубконто[ВидСубконто] = ДокументСсылка;
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

Функция ПолучитьПодразделение(РеквизитыПодразделения, Организация) Экспорт
	
	Ссылка = Справочники.ПодразделенияОрганизаций.ПолучитьСсылку(Новый УникальныйИдентификатор(РеквизитыПодразделения.ID));
	
	Если ОбщегоНазначения.СсылкаСуществует(Ссылка) Тогда
		Возврат Ссылка;
	Иначе
		
		Подразделение = Справочники.ПодразделенияОрганизаций.СоздатьЭлемент();
		Подразделение.УстановитьСсылкуНового(Ссылка);
		
		ЗаполнитьЗначенияСвойств(Подразделение, РеквизитыПодразделения, "Наименование,ОбособленноеПодразделение,КПП");
		
		Подразделение.Владелец = Организация;
		
		Подразделение.ОбменДанными.Загрузка = Истина;
		Подразделение.Записать();
		
		Возврат Подразделение.Ссылка;
		
	КонецЕсли;
	
КонецФункции

Функция ПодобратьВидСубконто(Счет, ТипЗначения) Экспорт
	
	Результат = Неопределено;
	
	Для Каждого СтрокаВидСубконто Из Счет.ВидыСубконто Цикл
		
		Если СтрокаВидСубконто.ВидСубконто.ТипЗначения.СодержитТип(ТипЗначения) Тогда
			Результат = СтрокаВидСубконто.ВидСубконто;
			Прервать;
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

Функция СсылкаНаДокумент(РеквизитыДокумента) Экспорт
	
	// Неподдерживаемый тип документа
	Если Метаданные.Документы.Найти(РеквизитыДокумента.Имя) = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	СсылкаНаДокумент = Документы[РеквизитыДокумента.Имя].ПолучитьСсылку(Новый УникальныйИдентификатор(РеквизитыДокумента.ID));
	
	Если Не ОбщегоНазначения.СсылкаСуществует(СсылкаНаДокумент) Тогда
		
		ДокументОбъект = Документы[РеквизитыДокумента.Имя].СоздатьДокумент();
		ДокументОбъект.УстановитьСсылкуНового(СсылкаНаДокумент);
		
		ЗаполнитьЗначенияСвойств(ДокументОбъект, РеквизитыДокумента, "Номер,Дата");
		
		ДокументОбъект.Организация = Справочники.Организации.ПолучитьСсылку(Новый УникальныйИдентификатор(РеквизитыДокумента.Организация));
		ДокументОбъект.ОбменДанными.Загрузка = Истина;
		ДокументОбъект.Записать();
		
	КонецЕсли;
	
	Возврат СсылкаНаДокумент;
	
КонецФункции

#КонецОбласти