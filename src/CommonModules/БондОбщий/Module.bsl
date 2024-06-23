#Область ПрограммныйИнтерфейс

Процедура ОчиститьСправочник(Справочник) Экспорт
	Выборка = Справочник.Выбрать();
    Пока Выборка.Следующий() Цикл
        Объект = Выборка.ПолучитьОбъект();
        Объект.Удалить()
	КонецЦикла;
КонецПроцедуры


// Проверка наличия SECID в текущем справочнике.
// 
// Параметры:
//  ЭлементСсылка - СправочникСсылка - Ссылка на текущий элемент справочника
//  SECID - Строка - SECID тикера
Процедура ПроверкаНаличияSECID(ЭлементСсылка, SECID) Экспорт
	ИмяСправочника = ЭлементСсылка.Метаданные().Имя;
	ШаблонЗапроса = "ВЫБРАТЬ
		|	Спр.Код
		|ИЗ
		|	Справочник.%1 КАК Спр
		|ГДЕ
		|	Спр.Ссылка <> &Ссылка
		|	И Спр.SECID = &SECID
		|	И Спр.ПометкаУдаления = ЛОЖЬ";
	
	Запрос = Новый Запрос;
	Запрос.Текст = СтрШаблон(ШаблонЗапроса, ИмяСправочника);
	
	Запрос.УстановитьПараметр("Ссылка", ЭлементСсылка);
	Запрос.УстановитьПараметр("SECID", SECID);
	
	Если НЕ Запрос.Выполнить().Пустой() Тогда
		ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
						        	НСтр("ru='Тикер с SECID <%1> уже присутствует в справочнике %2'"),
						        	SECID, ИмяСправочника);
	КонецЕсли;
КонецПроцедуры

// Загрузка данных тикера с MOEX.
// 
// Параметры:
//  SECID - Строка - SECID тикера
//  ЭлементОбъект - СправочникОбъект - Текущий элемент справочника
Процедура ЗагрузитьС_MOEX(SECID, ЭлементОбъект) Экспорт
	Тикер = ?(SECID=Неопределено, ЭлементОбъект.SECID, SECID);
	
//	URL = СтрШаблон(
//			"%1/%2.json?%3",
//			"https://iss.moex.com/iss/securities",
//			Тикер,
//			"iss.meta=off&iss.only=description,boards&primary_board=1&iss.json=extended"
//		);
	URL = СсылкаНаТикер(Тикер);

	ДопПараметры = КлиентHTTPКлиентСервер.НовыеДополнительныеПараметры();
	//@skip-check bsl-legacy-check-returning-type-for-environment
	Ответ = КлиентHTTPКлиентСервер.ТелоОтветаКакJSON(ДопПараметры).Получить(URL, , ДопПараметры);
	
	Если Ответ.КодСостояния <> 200 Тогда
		ТекстПредупреждения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
						        	НСтр("ru='Ошибка получения данных с биржи. Код ответа <%1>'"),
						        	Ответ.КодСостояния);
		#Если Сервер Тогда
		ОбщегоНазначения.СообщитьПользователю(ТекстПредупреждения);		
		#КонецЕсли						        	
		Возврат;		
	КонецЕсли;
	
	ТелоОтвета = Ответ.Тело[1];
	РеквизитыОбъекта = ЭлементОбъект.Метаданные().Реквизиты; 
	
	Если ТелоОтвета.description.Количество() = 0 Тогда
		#Если Сервер Тогда
		ОбщегоНазначения.СообщитьПользователю(НСтр("ru='Ошибка получения данных с биржи. Тикер не найден'"));		
		#КонецЕсли						        	
		Возврат;		
	КонецЕсли;
	
	ОчиститьОбъект(ЭлементОбъект);
	
	Для Каждого эл Из ТелоОтвета.description Цикл
		Если РеквизитыОбъекта.Найти(эл.name) = Неопределено Тогда
			Продолжить;			
		КонецЕсли;
		
		Если эл.type = "date" Тогда
			ЭлементОбъект[эл.name] = ПрочитатьДатуJSON(эл.value, ФорматДатыJSON.ISO);
		ИначеЕсли эл.type = "boolean" Тогда
			ЭлементОбъект[эл.name] = ?(эл.value = "1", Истина, Ложь);		
		Иначе
			ЭлементОбъект[эл.name] = эл.value;
		КонецЕсли;		
	КонецЦикла;
	ЭлементОбъект.Наименование = ЭлементОбъект.NAME;
	
	ЭлементОбъект.BOARDID = ТелоОтвета.boards[0].boardid;	
КонецПроцедуры

// Получение ссылки на тикер на сервере биржи
// 
// Параметры:
//  SECID - Строка - SECID тикера
//
// Возвращаемое значение:
//  Строка - URL
Функция СсылкаНаТикер(SECID) Экспорт
	URL = СтрШаблон(
			"%1/%2.json?%3",
			"https://iss.moex.com/iss/securities",
			SECID,
			"iss.meta=off&iss.only=description,boards&primary_board=1&iss.json=extended"
		);
	Возврат URL;	
КонецФункции
#КонецОбласти

#Область СлужебныеПроцедурыИФункции
// Очистить значения всех реквизитов элемента справочника
// 
// Параметры:
//  ЭлементОбъект - СправочникОбъект - Элемент справочника
Процедура ОчиститьОбъект(ЭлементОбъект)
	РеквизитыОбъекта = ЭлементОбъект.Метаданные().Реквизиты;
	Для Каждого Реквизит Из РеквизитыОбъекта Цикл
		ЭлементОбъект[Реквизит.Имя] = Неопределено;		
	КонецЦикла; 
КонецПроцедуры
#КонецОбласти
