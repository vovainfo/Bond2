///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2023, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ДеревоРеквизитов = РеквизитФормыВЗначение("РеквизитыОбъекта");
	КоллекцияРеквизитовОбъекта = ДеревоРеквизитов.Строки;
	
	ВыбраныВсеРеквизиты = Параметры.Отбор.Количество() = 0 Или Параметры.Отбор[0] = "*";
	ОбъектМетаданных = Параметры.Ссылка.Метаданные();
	Для Каждого ОписаниеРеквизита Из ОбъектМетаданных.Реквизиты Цикл
		Реквизит = КоллекцияРеквизитовОбъекта.Добавить();
		ЗаполнитьЗначенияСвойств(Реквизит, ОписаниеРеквизита);
		Реквизит.Пометка = ВыбраныВсеРеквизиты Или Параметры.Отбор.Найти(ОписаниеРеквизита.Имя) <> Неопределено;
		Реквизит.Синоним = ОписаниеРеквизита.Представление();
	КонецЦикла;
	
	КоллекцияРеквизитовОбъекта.Сортировать("Синоним");
	
	Для Каждого ОписаниеТабличнойЧасти Из ОбъектМетаданных.ТабличныеЧасти Цикл
		ТабличнаяЧасть = КоллекцияРеквизитовОбъекта.Добавить();
		ЗаполнитьЗначенияСвойств(ТабличнаяЧасть, ОписаниеТабличнойЧасти);
		ВыбранаВсяТабличнаяЧасть = ВыбраныВсеРеквизиты Или Параметры.Отбор.Найти(ОписаниеТабличнойЧасти.Имя + ".*") <> Неопределено;
		ЕстьВыбранныеЭлементы = ВыбранаВсяТабличнаяЧасть;
		Для Каждого ОписаниеРеквизита Из ОписаниеТабличнойЧасти.Реквизиты Цикл
			Реквизит = ТабличнаяЧасть.Строки.Добавить();
			ЗаполнитьЗначенияСвойств(Реквизит, ОписаниеРеквизита);
			Реквизит.Синоним = ОписаниеРеквизита.Представление();
			Реквизит.Пометка = ВыбраныВсеРеквизиты Или ВыбранаВсяТабличнаяЧасть Или Параметры.Отбор.Найти(ОписаниеТабличнойЧасти.Имя + "." + ОписаниеРеквизита.Имя) <> Неопределено;
			ЕстьВыбранныеЭлементы = ЕстьВыбранныеЭлементы Или Реквизит.Пометка;
		КонецЦикла;
		ТабличнаяЧасть.Пометка = ЕстьВыбранныеЭлементы + ?(ЕстьВыбранныеЭлементы, (Не ВыбранаВсяТабличнаяЧасть), ЕстьВыбранныеЭлементы);
		ТабличнаяЧасть.Строки.Сортировать("Синоним");
	КонецЦикла;
	
	ЗначениеВРеквизитФормы(ДеревоРеквизитов, "РеквизитыОбъекта");
	
	ВерсионированиеОбъектовПереопределяемый.ПриВыбореРеквизитовОбъекта(Параметры.Ссылка, РеквизитыОбъекта);
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормыРеквизитыОбъекта

&НаКлиенте
Процедура РеквизитыОбъектаПометкаПриИзменении(Элемент)
	
	ПриИзмененииФлажка(Элементы.РеквизитыОбъекта, "Пометка");
	УстановитьДоступностьКнопкиВыбора();

КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура УстановитьФлажки(Команда)
	УстановитьСнятьФлажки(Истина);
КонецПроцедуры

&НаКлиенте
Процедура СнятьФлажки(Команда)
	УстановитьСнятьФлажки(Ложь);
КонецПроцедуры

&НаКлиенте
Процедура Выбрать(Команда)
	Результат = Новый Структура;
	Результат.Вставить("ВыбранныеРеквизиты", ВыбранныеРеквизиты(РеквизитыОбъекта.ПолучитьЭлементы()));
	Результат.Вставить("ПредставлениеВыбранных", ПредставлениеВыбранныхРеквизитов());

	Закрыть(Результат);
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура УстановитьСнятьФлажки(Пометка)
	Для Каждого Реквизит Из РеквизитыОбъекта.ПолучитьЭлементы() Цикл 
		Реквизит.Пометка = Пометка;
		Для Каждого ПодчиненныйРеквизит Из Реквизит.ПолучитьЭлементы() Цикл
			ПодчиненныйРеквизит.Пометка = Пометка;
		КонецЦикла;
	КонецЦикла;
	УстановитьДоступностьКнопкиВыбора();
КонецПроцедуры

&НаКлиенте
Функция ВыбранныеРеквизиты(КоллекцияРеквизитов)
	Результат = Новый Массив;
	ВыбраныВсеРеквизиты = Истина;
	
	Для Каждого Реквизит Из КоллекцияРеквизитов Цикл
		ПодчиненныеРеквизиты = Реквизит.ПолучитьЭлементы();
		Если ПодчиненныеРеквизиты.Количество() > 0 Тогда
			СписокВыбранных = ВыбранныеРеквизиты(ПодчиненныеРеквизиты);
			ВыбраныВсеРеквизиты = ВыбраныВсеРеквизиты И СписокВыбранных.Количество() = 1 И СписокВыбранных[0] = "*";
			Для Каждого ПодчиненныйРеквизит Из СписокВыбранных Цикл
				Результат.Добавить(Реквизит.Имя + "." + ПодчиненныйРеквизит);
			КонецЦикла;
		Иначе
			ВыбраныВсеРеквизиты = ВыбраныВсеРеквизиты И Реквизит.Пометка;
			Если Реквизит.Пометка Тогда
				Результат.Добавить(Реквизит.Имя);
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	
	Если ВыбраныВсеРеквизиты Тогда
		Результат.Очистить();
		Результат.Добавить("*");
	КонецЕсли;
	
	Возврат Результат;
КонецФункции

&НаКлиенте
Функция ПредставлениеВыбранныхРеквизитов()
	Результат = СтрСоединить(СинонимыВыбранныхРеквизитов(), ", ");
	Если Результат = "*" Тогда
		Результат = НСтр("ru = 'Все реквизиты'");
	КонецЕсли;
	
	Возврат Результат;
КонецФункции

&НаСервере
Функция СинонимыВыбранныхРеквизитов()
	Результат = Новый Массив;
	
	КоллекцияРеквизитов = РеквизитФормыВЗначение("РеквизитыОбъекта");
	
	ВыбранныеРеквизиты = КоллекцияРеквизитов.Строки.НайтиСтроки(Новый Структура("Пометка", 1));
	Если ВыбранныеРеквизиты.Количество() = КоллекцияРеквизитов.Строки.Количество() Тогда
		Результат.Добавить("*");
		Возврат Результат;
	КонецЕсли;
	
	Для Каждого Реквизит Из ВыбранныеРеквизиты Цикл
		Результат.Добавить(Реквизит.Синоним);
	КонецЦикла;
	
	ВыбранныеРеквизиты = КоллекцияРеквизитов.Строки.НайтиСтроки(Новый Структура("Пометка", 2));
	Для Каждого Реквизит Из ВыбранныеРеквизиты Цикл
		ПодчиненныеРеквизиты = Реквизит.Строки;
		Для Каждого ПодчиненныйРеквизит Из ПодчиненныеРеквизиты Цикл
			Если ПодчиненныйРеквизит.Пометка Тогда
				Результат.Добавить(Реквизит.Синоним + "." + ПодчиненныйРеквизит.Синоним);
			КонецЕсли;
		КонецЦикла;
	КонецЦикла;
	
	Возврат Результат;
КонецФункции


// Устанавливает связанные флажки.
&НаКлиенте
Процедура ПриИзмененииФлажка(ДеревоФормы, ИмяФлажка)
	
	ТекущиеДанные = ДеревоФормы.ТекущиеДанные;
	
	Если ТекущиеДанные[ИмяФлажка] = 2 Тогда
		ТекущиеДанные[ИмяФлажка] = 0;
	КонецЕсли;
	
	Пометка = ТекущиеДанные[ИмяФлажка];
	
	// Обновление подчиненных флажков.
	Для Каждого ПодчиненныйРеквизит Из ТекущиеДанные.ПолучитьЭлементы() Цикл
		ПодчиненныйРеквизит[ИмяФлажка] = Пометка;
	КонецЦикла;
	
	// Обновление родительского флажка.
	Родитель = ТекущиеДанные.ПолучитьРодителя();
	Если Родитель <> Неопределено Тогда
		ЕстьВыбранныеЭлементы = Ложь;
		ВыбраныВсеЭлементы = Истина;
		Для Каждого Элемент Из Родитель.ПолучитьЭлементы() Цикл
			ЕстьВыбранныеЭлементы = ЕстьВыбранныеЭлементы Или Элемент[ИмяФлажка];
			ВыбраныВсеЭлементы = ВыбраныВсеЭлементы И Элемент[ИмяФлажка];
		КонецЦикла;
		Родитель[ИмяФлажка] = ЕстьВыбранныеЭлементы + ?(ЕстьВыбранныеЭлементы, (Не ВыбраныВсеЭлементы), ЕстьВыбранныеЭлементы);
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура УстановитьДоступностьКнопкиВыбора()
	Элементы.РеквизитыОбъектаВыбрать.Доступность = ВыбранныеРеквизиты(РеквизитыОбъекта.ПолучитьЭлементы()).Количество() > 0
КонецПроцедуры

#КонецОбласти
