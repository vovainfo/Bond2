
#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ПрограммныйИнтерфейс
// Загрузить акцию с MOEX.
// 
// Параметры:
//  SECID - Строка
//  АкцияОбъект  - СправочникОбъект.Акции
Процедура ЗагрузитьАкциюС_MOEX(SECID, АкцияОбъект = Неопределено) Экспорт
	Акция = АкцияОбъект;
	Если АкцияОбъект = Неопределено Тогда
		Акция = СоздатьЭлемент();
	КонецЕсли;
		
	Переименования = Справочники.Переименования.СписокПереименований(SECID);
	БондОбщий.ЗагрузитьТикерС_MOEX(Переименования[Переименования.Количество()-1].Код, Акция);
	Сплиты = Справочники.Сплиты.СписокСплитов(Переименования.ВыгрузитьКолонку("Код"));
	Для Каждого Элемент Из Переименования Цикл
		ЗаполнитьЗначенияСвойств(Акция.ТорговыеКоды.Добавить(), Элемент);
	КонецЦикла;
	Для Каждого Элемент Из Сплиты Цикл
		ЗаполнитьЗначенияСвойств(Акция.Сплиты.Добавить(), Элемент);
	КонецЦикла;
	
	Если АкцияОбъект = Неопределено Тогда
		Акция.Записать();
	КонецЕсли;
КонецПроцедуры
#КонецОбласти

//@skip-check module-region-empty
#Область ОбработчикиСобытий
#КонецОбласти

//@skip-check module-region-empty
#Область СлужебныйПрограммныйИнтерфейс
#КонецОбласти

//@skip-check module-region-empty
#Область СлужебныеПроцедурыИФункции
#КонецОбласти

#КонецЕсли
