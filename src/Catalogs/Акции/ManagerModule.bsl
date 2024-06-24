
#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ПрограммныйИнтерфейс
// Загрузить акцию с MOEX.
// 
// Параметры:
//  АкцияОбъект  - СправочникОбъект.Акции
//  SECID - Строка
Процедура ЗагрузитьАкциюС_MOEX(АкцияОбъект, SECID) Экспорт
	Переименования = Справочники.Переименования.СписокПереименований(SECID);
	БондОбщий.ЗагрузитьТикерС_MOEX(Переименования[Переименования.Количество()-1].Код, АкцияОбъект);
	АкцияОбъект.ИзменениеТорговыхКодов.Очистить();
	Для Каждого Элемент Из Переименования Цикл
		ЭлементТЧ = АкцияОбъект.ИзменениеТорговыхКодов.Добавить();
		ЗаполнитьЗначенияСвойств(ЭлементТЧ, Элемент);		
	КонецЦикла;
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
