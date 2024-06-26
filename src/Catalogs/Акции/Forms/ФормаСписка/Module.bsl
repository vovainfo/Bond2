//@skip-check module-region-empty
#Область ОписаниеПеременных
#КонецОбласти

//@skip-check module-region-empty
#Область ОбработчикиСобытийФормы
#КонецОбласти



//@skip-check module-region-empty
#Область ОбработчикиСобытийЭлементовШапкиФормы
#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормыСписок
&НаСервереБезКонтекста
Процедура СписокПриПолученииДанныхНаСервере(ИмяЭлемента, Настройки, Строки)
	Для Каждого Элемент Из Строки Цикл
		// Запрос в цикле - очень плохо. Но иначе будет очень плохо читаемо
		Запрос = Новый Запрос;
		Запрос.Текст =
			"ВЫБРАТЬ
			|	АкцииТорговыеКоды.Код
			|ИЗ
			|	Справочник.Акции.ТорговыеКоды КАК АкцииТорговыеКоды
			|ГДЕ
			|	АкцииТорговыеКоды.Ссылка = &Ссылка
			|	И АкцииТорговыеКоды.Код <> АкцииТорговыеКоды.Ссылка.SECID";
		
		Запрос.УстановитьПараметр("Ссылка", Элемент.Ключ);
		
		//@skip-check query-in-loop
		Коды = Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("Код");
		Элемент.Значение.Данные.ИсторияSECID = СтрСоединить(Коды,",");
	КонецЦикла;
КонецПроцедуры
#КонецОбласти

//@skip-check module-region-empty
#Область ОбработчикиКомандФормы
#КонецОбласти

//@skip-check module-region-empty
#Область СлужебныеПроцедурыИФункции
#КонецОбласти
