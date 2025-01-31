﻿
#Область СлужебныйПрограммныйИнтерфейс

&После("ЗаполнитьПравилаОбработкиДанных")
Процедура uu_ЗаполнитьПравилаОбработкиДанных(НаправлениеОбмена, ПравилаОбработкиДанных)
	
	Если НаправлениеОбмена = "Отправка" Тогда
		ДобавитьПОД_Документ_ОперацияКОтражениюВУпрУчете_Отправка(ПравилаОбработкиДанных);
	КонецЕсли;
	
КонецПроцедуры

&После("ЗаполнитьПравилаКонвертацииОбъектов")
Процедура uu_ЗаполнитьПравилаКонвертацииОбъектов(НаправлениеОбмена, ПравилаКонвертации)

	Если НаправлениеОбмена = "Отправка" Тогда
		ДобавитьПКО_Документ_ОперацияКОтражениюВУпрУчете_Отправка(ПравилаКонвертации);	
	КонецЕсли;

КонецПроцедуры

&После("ВыполнитьПроцедуруМодуляМенеджера")
Процедура uu_ВыполнитьПроцедуруМодуляМенеджера(ИмяПроцедуры, Параметры)
	
	Если ИмяПроцедуры = "ПКО_Документ_ОперацияКОтражениюВУпрУчете_Отправка_ПриОтправкеДанных" Тогда 
		ПКО_Документ_ОперацияКОтражениюВУпрУчете_Отправка_ПриОтправкеДанных(
			Параметры.ДанныеИБ, Параметры.ДанныеXDTO, Параметры.КомпонентыОбмена, Параметры.СтекВыгрузки);
	КонецЕсли;
		
КонецПроцедуры

#КонецОбласти

#Область Документ_ОперацияКОтражениюВУпрУчете

Процедура ДобавитьПОД_Документ_ОперацияКОтражениюВУпрУчете_Отправка(ПравилаОбработкиДанных)
	
	ПравилоОбработки                         = ПравилаОбработкиДанных.Добавить();
	ПравилоОбработки.Имя                     = "Документ_ОперацияКОтражениюВУпрУчете_Отправка";
	ПравилоОбработки.ОбъектВыборкиМетаданные = Метаданные.Документы.uu_ОперацияКОтражениюВУпрУчете;

	ПравилоОбработки.ИспользуемыеПКО.Добавить("Документ_ОперацияКОтражениюВУпрУчете_Отправка");
	
КонецПроцедуры

Процедура ДобавитьПКО_Документ_ОперацияКОтражениюВУпрУчете_Отправка(ПравилаКонвертации)
	
	ПравилоКонвертации = ОбменДаннымиXDTOСервер.ИнициализироватьПравилоКонвертацииОбъекта(ПравилаКонвертации);
	
	ПравилоКонвертации.ИмяПКО            = "Документ_ОперацияКОтражениюВУпрУчете_Отправка";
	ПравилоКонвертации.ОбъектДанных      = Метаданные.Документы.uu_ОперацияКОтражениюВУпрУчете;
	ПравилоКонвертации.ОбъектФормата     = "Документ.ОперацияБух";
	ПравилоКонвертации.ПриОтправкеДанных = "ПКО_Документ_ОперацияКОтражениюВУпрУчете_Отправка_ПриОтправкеДанных";
	
	ОбменДаннымиXDTOСервер.ИнициализироватьРасширениеПравилаКонвертацииОбъекта(ПравилоКонвертации, "http://v8.1c.ru/edi/edi_stnd/ED_UU/1.0");
	
	СвойстваШапки = ПравилоКонвертации.Свойства;
	
	ДобавитьПКС(СвойстваШапки, "Дата", "Дата", , , "http://v8.1c.ru/edi/edi_stnd/ED_UU/1.0"); 
	ДобавитьПКС(СвойстваШапки, , "Содержание", 1, , "http://v8.1c.ru/edi/edi_stnd/ED_UU/1.0");
	ДобавитьПКС(СвойстваШапки, , "Комментарий", 1, , "http://v8.1c.ru/edi/edi_stnd/ED_UU/1.0");
	ДобавитьПКС(СвойстваШапки, "", "Организация", 1, "Справочник_Организации_Отправка", "http://v8.1c.ru/edi/edi_stnd/ED_UU/1.0");
	ДобавитьПКС(СвойстваШапки, "", "СуммаОперации", 1, , "http://v8.1c.ru/edi/edi_stnd/ED_UU/1.0");
		
КонецПроцедуры

Процедура ПКО_Документ_ОперацияКОтражениюВУпрУчете_Отправка_ПриОтправкеДанных(ДанныеИБ, ДанныеXDTO, КомпонентыОбмена, СтекВыгрузки)
	
	ДанныеXDTO.КлючевыеСвойства.Вставить("Организация", ОбщегоНазначения.ЗначениеРеквизитаОбъекта(ДанныеИБ.ПервичныйДокумент, "Организация"));
	ДанныеXDTO.КлючевыеСвойства.Вставить("Содержание", Строка(ДанныеИБ.ПервичныйДокумент));
	
	Если ОбщегоНазначения.ЕстьРеквизитОбъекта("Комментарий", ДанныеИБ.ПервичныйДокумент.Метаданные()) Тогда
		ДанныеXDTO.КлючевыеСвойства.Вставить("Комментарий", ОбщегоНазначения.ЗначениеРеквизитаОбъекта(ДанныеИБ.ПервичныйДокумент, "Комментарий"));	
	КонецЕсли;
	
	НаборЗаписей = РегистрыБухгалтерии.Хозрасчетный.СоздатьНаборЗаписей();
	НаборЗаписей.Отбор.Регистратор.Установить(ДанныеИБ.ПервичныйДокумент);
	НаборЗаписей.Прочитать();
	
	ДанныеXDTO.КлючевыеСвойства.Вставить("СуммаОперации", НаборЗаписей.Итог("Сумма"));
	
	ТаблицаДвижений = НаборЗаписей.Выгрузить();
	
	МассивДвижений = Новый Массив; 
	
	Для Каждого Запись Из ТаблицаДвижений Цикл
		
		Если Не Запись.Активность Тогда
			Продолжить;
		КонецЕсли;
		
		СтруктураЗаписи = Новый Структура;
		СтруктураЗаписи.Вставить("Период", 			Запись.Период);
		СтруктураЗаписи.Вставить("ПодразделениеДт", uu_ОбработкаОперацийУпрУчет.ОписаниеПодразделения(Запись.ПодразделениеДт));
		СтруктураЗаписи.Вставить("ВалютаДт", 		Запись.ВалютаДт.Код);
		СтруктураЗаписи.Вставить("СчетДт", 			Запись.СчетДт.Код);
		СтруктураЗаписи.Вставить("СубконтоДт1", 	uu_ОбработкаОперацийУпрУчет.ОписаниеСубконто(Запись.СубконтоДт1));
		СтруктураЗаписи.Вставить("СубконтоДт2", 	uu_ОбработкаОперацийУпрУчет.ОписаниеСубконто(Запись.СубконтоДт2));
		СтруктураЗаписи.Вставить("СубконтоДт3", 	uu_ОбработкаОперацийУпрУчет.ОписаниеСубконто(Запись.СубконтоДт3));
		СтруктураЗаписи.Вставить("КоличествоДт", 	Запись.КоличествоДт); 
		СтруктураЗаписи.Вставить("ВалютнаяСуммаДт", Запись.ВалютнаяСуммаДт);
		СтруктураЗаписи.Вставить("ВалютаКт", 		Запись.ВалютаКт.Код);
		СтруктураЗаписи.Вставить("ПодразделениеКт", uu_ОбработкаОперацийУпрУчет.ОписаниеПодразделения(Запись.ПодразделениеКт));
		СтруктураЗаписи.Вставить("СчетКт", 			Запись.СчетКт.Код);
		СтруктураЗаписи.Вставить("СубконтоКт1", 	uu_ОбработкаОперацийУпрУчет.ОписаниеСубконто(Запись.СубконтоКт1));
		СтруктураЗаписи.Вставить("СубконтоКт2", 	uu_ОбработкаОперацийУпрУчет.ОписаниеСубконто(Запись.СубконтоКт2));
		СтруктураЗаписи.Вставить("СубконтоКт3", 	uu_ОбработкаОперацийУпрУчет.ОписаниеСубконто(Запись.СубконтоКт3));
		СтруктураЗаписи.Вставить("КоличествоКт", 	Запись.КоличествоКт); 
		СтруктураЗаписи.Вставить("ВалютнаяСуммаКт", Запись.ВалютнаяСуммаКт);
		СтруктураЗаписи.Вставить("Сумма", 			Запись.Сумма);
		СтруктураЗаписи.Вставить("Содержание", 		Запись.Содержание);
		
		МассивДвижений.Добавить(СтруктураЗаписи);
		
	КонецЦикла;
	
	ДанныеXDTO.Вставить("AdditionalInfo", Новый Структура("Движения,ПометкаУдаления", МассивДвижений, ДанныеИБ.ПометкаУдаления));
	
КонецПроцедуры

#КонецОбласти