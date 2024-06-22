
// SPDX-License-Identifier: Apache-2.0+

#Область ПрограммныйИнтерфейс
// Реализация POST типа application/x-www-form-urlencoded
//
// Параметры:
//  ИдентификаторРесурса	 - Строка, Структура - URI сервиса либо объект идентификатора ресурса
//  Данные					 - Массив			 - поля HTML-формы. Элементы - Структура с ключами:
//  * Ключ - Строка - имя поля
//  * Значение - Строка - значение поля
//  ДополнительныеПараметры	 - Структура		 - конфигурация выполнения запроса
//  ПараметрыЗапроса		 - Соответствие		 - коллекция параметров запроса
// 
// Возвращаемое значение:
//  Обещание - содержит объект ответа (ФиксированнаяСтруктура):
//  * КодСостояния - Число - код состояния (ответа) HTTP-сервера,
//  * Заголовки - Соответствие - HTTP-заголовки ответа сервера в виде соответствия "Название заголовка" - "Значение",
//  * Тело - ДвоичныеДанные, Строка, Структура, Соответствие, ОбъектXDTO, ЗначениеXDTO, Неопределено - данные тела HTTP-ответа,
//  * ИмяФайлаТела - Строка, Неопределено - имя файла, в который было записано тело ответа
//
Асинх Функция ОтправитьДанныеHTMLФормы(ИдентификаторРесурса, Данные, ДополнительныеПараметры = Неопределено, ПараметрыЗапроса = Неопределено) Экспорт
	Если ДополнительныеПараметры = Неопределено Тогда
		ДополнительныеПараметры = КлиентHTTPКлиентСервер.НовыеДополнительныеПараметры();
	КонецЕсли;
	
	КлиентHTTPКлиентСервер.УстановитьТипMIME(ДополнительныеПараметры, КлиентHTTPПовтИсп.ТипMIMEXWWWFormUrlEncoded());
	
	Данные = КлиентHTTPВызовСервера.ЗакодированныеПоляФормыHTML(Данные);
	ИндексПоследнегоПоля = Данные.ВГраница();
	Поток = Новый ПотокВПамяти;
	Запись = Новый ЗаписьДанных(Поток, КлиентHTTPКлиентСервер.КодировкаИзДопПараметров(ДополнительныеПараметры), , "");
	
	Для я = 0 По ИндексПоследнегоПоля Цикл
		ПолеФормы = Данные[я];
		ЕстьЗначениеПоля = (ПолеФормы.Значение <> "");
		РазделительВнешний = ?(я = ИндексПоследнегоПоля, "", "&");
		РазделительВнутренний = ?(ЕстьЗначениеПоля, "=", РазделительВнешний);
		
		Ждать Запись.ЗаписатьСтрокуАсинх(ПолеФормы.Ключ, , РазделительВнутренний);
		Если ЕстьЗначениеПоля Тогда
			Ждать Запись.ЗаписатьСтрокуАсинх(ПолеФормы.Значение, , РазделительВнешний);
		КонецЕсли;
	КонецЦикла;
	
	Возврат КлиентHTTPКлиентСервер.ОтправитьДвоичныеДанные(ИдентификаторРесурса, Поток.ЗакрытьИПолучитьДвоичныеДанные(), ДополнительныеПараметры, ПараметрыЗапроса);
КонецФункции

// Реализация POST типа multipart/form-data. При отсутствии файла генерируется исключение
//
// Параметры:
//  ИдентификаторРесурса	 - Строка, Структура - URI сервиса либо объект идентификатора ресурса
//  Данные					 - Массив			 - тело запроса. Элементы - Структура с ключами:
//  * Ключ - Строка - имя поля
//  * Значение - Строка, Файл - значение поля
//  * ТипMIME - Строка - тип значения поля
//  * Файл - Структура, ключи:
//    ** Имя		 - Строка - имя файла,
//    ** ТипMIME	 - Строка - MIME-тип содержимого файла,
//    ** Кодировка	 - Строка - кодировка файла
//  ДополнительныеПараметры	 - Структура    - конфигурация выполнения запроса
//  ПараметрыЗапроса		 - Соответствие - коллекция параметров запроса
// 
// Возвращаемое значение:
//  Обещание - содержит объект ответа (ФиксированнаяСтруктура):
//  * КодСостояния - Число - код состояния (ответа) HTTP-сервера,
//  * Заголовки - Соответствие - HTTP-заголовки ответа сервера в виде соответствия "Название заголовка" - "Значение",
//  * Тело - ДвоичныеДанные, Строка, Структура, Соответствие, ОбъектXDTO, ЗначениеXDTO, Неопределено - данные тела HTTP-ответа,
//  * ИмяФайлаТела - Строка, Неопределено - имя файла, в который было записано тело ответа
//
Асинх Функция ОтправитьДанныеФормы(ИдентификаторРесурса, Данные, ДополнительныеПараметры = Неопределено, ПараметрыЗапроса = Неопределено) Экспорт
	Если ДополнительныеПараметры = Неопределено Тогда
		ДополнительныеПараметры = КлиентHTTPКлиентСервер.НовыеДополнительныеПараметры();
	КонецЕсли;
	
	Разделитель = ?(ДополнительныеПараметры.Свойство("Разделитель"), ДополнительныеПараметры.Разделитель, XMLСтрока(Новый УникальныйИдентификатор));
	_Разделитель = "--" + Разделитель;
	_Разделитель_ = _Разделитель + "--";
	
	КлиентHTTPКлиентСервер.УстановитьТипMIME(ДополнительныеПараметры, КлиентHTTPПовтИсп.ТипMIMEMultipartFromData());
	
	Поток = Новый ПотокВПамяти;
	Запись = Новый ЗаписьДанных(Поток, КлиентHTTPКлиентСервер.КодировкаИзДопПараметров(ДополнительныеПараметры));
	
	Для Каждого ПолеФормы Из Данные Цикл
		Ждать Запись.ЗаписатьСтрокуАсинх("");
		Ждать Запись.ЗаписатьСтрокуАсинх(_Разделитель);
		
		Если ПолеФормы.Свойство("Файл") Тогда
			Ждать ДобавитьДанныеФормыФайл(ПолеФормы, Запись);
		Иначе
			Ждать ДобавитьДанныеФормыТекст(ПолеФормы, Запись);
		КонецЕсли;
		
		Ждать Запись.ЗаписатьСтрокуАсинх(_Разделитель_);
	КонецЦикла;
	
	Возврат КлиентHTTPКлиентСервер.ОтправитьДвоичныеДанные(ИдентификаторРесурса, Поток.ЗакрытьИПолучитьДвоичныеДанные(), ДополнительныеПараметры, ПараметрыЗапроса);
КонецФункции

// Возвращает обещание с объектом обработанного HTTP-ответа
//
// Параметры:
//  Ответ					 - HTTPОтвет - ответ HTTP-сервера на HTTP-запрос
//  ДополнительныеПараметры	 - Структура - конфигурация выполнения HTTP-запроса
//  КонтекстВыполнения		 - Структура - контекст выполнения запроса
// 
// Возвращаемое значение:
//  Обещание - содержит объект ответа (ФиксированнаяСтруктура):
//  * КодСостояния - Число - код состояния (ответа) HTTP-сервера,
//  * Заголовки - Соответствие - HTTP-заголовки ответа сервера в виде соответствия "Название заголовка" - "Значение",
//  * Тело - ДвоичныеДанные, Строка, Структура, Соответствие, ОбъектXDTO, ЗначениеXDTO, Неопределено - данные тела HTTP-ответа,
//  * ИмяФайлаТела - Строка, Неопределено - имя файла, в который было записано тело ответа,
//  * КонтекстВыполнения - Структура - контекст выполнения запроса
//
Асинх Функция ОбъектОбработанногоОтвета(Знач Ответ, Знач ДополнительныеПараметры, Знач КонтекстВыполнения) Экспорт
	фРезультат = КлиентHTTPКлиентСервер.НовыйОбъектОбработанногоОтвета();
	фРезультат.КодСостояния = Ответ.КодСостояния;
	фРезультат.Заголовки = Ответ.Заголовки;
	фРезультат.Тело = Ждать ТелоОтвета(Ответ, ДополнительныеПараметры);
	фРезультат.ИмяФайлаТела = Ответ.ПолучитьИмяФайлаТела();
	фРезультат.КонтекстВыполнения = КонтекстВыполнения.Значения;
	
	Возврат Новый ФиксированнаяСтруктура(фРезультат);
КонецФункции

// Создаёт файл путём конкатенации файлов сертификата и ключа формата PEM.
//
// Параметры:
//  ИмяФайла			 - Строка	 - полное имя создаваемого файла
//  Сертификат			 - Файл		 - файл сертификата формата PEM
//  Ключ				 - Файл		 - файл ключа сертификата формата PEM
//  ЗапретитьПерезапись	 - Булево	 - режим проаерки на существование создаваемого файла: если Истина, то вернётся ошибка в случае существования файла по указанному имени (возможен вызов исключения)
// 
// Возвращаемое значение:
//  Обещание - объект ответа:
//  * Ошибка - Булево - признак наличия ошибки
//  * ОписаниеОшибки - Строка - описание ошибки
//
Асинх Функция ОбъединенныйФайлСертификатаИКлючаPEM(Знач ИмяФайла, Знач Сертификат, Знач Ключ, Знач ЗапретитьПерезапись = Ложь) Экспорт
	фРезультат = Новый Структура("Ошибка, ОписаниеОшибки", Истина, "");
	Если НЕ Ждать Сертификат.СуществуетАсинх() Тогда
		фРезультат.ОписаниеОшибки = "не найден файл сертификата " + Сертификат.ПолноеИмя;
		Возврат фРезультат;
	КонецЕсли;
	Если НЕ Ждать Ключ.СуществуетАсинх() Тогда
		фРезультат.ОписаниеОшибки = "не найден файл ключа " + Ключ.ПолноеИмя;
		Возврат фРезультат;
	КонецЕсли;
	
	Если ЗапретитьПерезапись Тогда
		Ф = Новый Файл(ИмяФайла);
		Если Ждать Ф.СуществуетАсинх() Тогда
			фРезультат.ОписаниеОшибки = "файл уже существует: " + Ф.ПолноеИмя;
			Возврат фРезультат;
		КонецЕсли;
		Режим = РежимОткрытияФайла.СоздатьНовый;
	Иначе
		Режим = РежимОткрытияФайла.Создать;
	КонецЕсли;
	
	Поток = Новый ФайловыйПоток(ИмяФайла, Режим);
	Если НЕ Поток.ДоступнаЗапись Тогда
		Поток.ЗакрытьАсинх();
		фРезультат.ОписаниеОшибки = "не доступна запись в файл " + ИмяФайла;
		Возврат фРезультат;
	КонецЕсли;
	
	Запись = Новый ЗаписьДанных(Поток);
	Ждать Запись.ЗаписатьАсинх(Новый ДвоичныеДанные(Сертификат.ПолноеИмя));
	Ждать Запись.ЗаписатьАсинх(Новый ДвоичныеДанные(Ключ.ПолноеИмя));
	
	Поток.ЗакрытьАсинх();
	
	фРезультат.Ошибка = Ложь;
	Возврат фРезультат;
КонецФункции
#КонецОбласти

#Область СлужебныеПроцедурыИФункции
Асинх Функция ТелоОтвета(Ответ, ДополнительныеПараметры)
	ДанныеТелаОтвета = ?(
		КлиентHTTPКлиентСервер.ЗначениеЗаголовка(КлиентHTTPПовтИсп.ЗаголовокОтветаСжатиеТела(), Ответ.Заголовки) = Неопределено,
		Ответ.ПолучитьТелоКакДвоичныеДанные(),
		Ждать Декомпрессия(Ответ.ПолучитьТелоКакПоток())
	);
	
	Возврат ?(
		ДополнительныеПараметры.Свойство("ПрочитатьТелоОтветаКак"),
		КлиентHTTPКлиентСервер.ПреобразованноеТелоОтвета(Ответ, ДанныеТелаОтвета, ДополнительныеПараметры.ПрочитатьТелоОтветаКак),
		ДанныеТелаОтвета
	);
КонецФункции

Асинх Функция Декомпрессия(ПотокСжатыхДанных)
#Если МобильноеПриложениеКлиент ИЛИ МобильныйКлиент Тогда
	ВызватьИсключение "Функционал не поддерживается в мобильном приложении";
#Иначе
	ИмяФайлаВАрхиве = ПолучитьБуферДвоичныхДанныхИзСтроки(Сред(Новый УникальныйИдентификатор, 25), КодировкаТекста.ANSI, Ложь);
	РазмерАрхива = Ждать ПотокСжатыхДанных.РазмерАсинх();
	РазмерСжатыхДанных = РазмерАрхива - 18; // размер префикса + размер постфикса GZip = 18
	
	// Восстановление структуры ZIP-архива
	
	ОбластиZIP = КлиентHTTPПовтИсп.ОбластиФайлаВАрхивеZIP();
	Поток = Новый ПотокВПамяти(ОбластиZIP.РазмерLFH + РазмерСжатыхДанных + ОбластиZIP.РазмерDD + ОбластиZIP.РазмерCDFH + ОбластиZIP.РазмерEOCD);
	
	ОбластиZIP.ОбластьLFH.Записать(30, ИмяФайлаВАрхиве);
	
	Чтение = Новый ЧтениеДанных(ПотокСжатыхДанных);
	Ждать Чтение.ПропуститьАсинх(10); // размер префикса GZip
	
	Запись = Новый ЗаписьДанных(Поток);
	Ждать Запись.ЗаписатьБуферДвоичныхДанныхАсинх(ОбластиZIP.ОбластьLFH);
	Ждать Чтение.КопироватьВАсинх(Запись, РазмерСжатыхДанных);
	Ждать Запись.ЗакрытьАсинх();
	
	КонтрольнаяСумма = Ждать Чтение.ПрочитатьЦелое32Асинх();
	РазмерНесжатыхДанных = Ждать Чтение.ПрочитатьЦелое32Асинх();
	
	Ждать Чтение.ЗакрытьАсинх();
	
	ОбластиZIP.ОбластьDD.ЗаписатьЦелое32(4, КонтрольнаяСумма);
	ОбластиZIP.ОбластьDD.ЗаписатьЦелое32(8, РазмерСжатыхДанных);
	ОбластиZIP.ОбластьDD.ЗаписатьЦелое32(12, РазмерНесжатыхДанных);

	ОбластиZIP.ОбластьCDFH.ЗаписатьЦелое32(16, КонтрольнаяСумма);
	ОбластиZIP.ОбластьCDFH.ЗаписатьЦелое32(20, РазмерСжатыхДанных);
	ОбластиZIP.ОбластьCDFH.ЗаписатьЦелое32(24, РазмерНесжатыхДанных);
	ОбластиZIP.ОбластьCDFH.Записать(46, ИмяФайлаВАрхиве);

	ОбластиZIP.ОбластьEOCD.ЗаписатьЦелое32(16, ОбластиZIP.РазмерLFH + РазмерСжатыхДанных + ОбластиZIP.РазмерDD);
	
	Запись = Новый ЗаписьДанных(Поток);
	Ждать Запись.ЗаписатьБуферДвоичныхДанныхАсинх(ОбластиZIP.ОбластьDD);
	Ждать Запись.ЗаписатьБуферДвоичныхДанныхАсинх(ОбластиZIP.ОбластьCDFH);
	Ждать Запись.ЗаписатьБуферДвоичныхДанныхАсинх(ОбластиZIP.ОбластьEOCD);
	Ждать Запись.ЗакрытьАсинх();
	
	// Извлечение содержимого ZIP-архива
	
	Каталог = ПолучитьИмяВременногоФайла();
	Чтение = Новый ЧтениеZipФайла(Поток);
	ИмяФайла = Чтение.Элементы[0].Имя;
	Чтение.Извлечь(Чтение.Элементы[0], Каталог, РежимВосстановленияПутейФайловZIP.НеВосстанавливать);
	Чтение.Закрыть();
	
	фРезультат = Новый ДвоичныеДанные(Каталог + ПолучитьРазделительПутиКлиента() + ИмяФайла);
	Попытка
		Ждать УдалитьФайлыАсинх(Каталог);
	Исключение
		КлиентHTTPВызовСервера.ДобавитьЗаписьОшибкиВЖурналРегистрации(Каталог, ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
	КонецПопытки;
	
	Возврат фРезультат;
#КонецЕсли
КонецФункции

Асинх Функция ДобавитьДанныеФормыТекст(ПолеФормы, ЗаписьДанныхФормы)
	Ждать ЗаписьДанныхФормы.ЗаписатьСтрокуАсинх(СтрШаблон("Content-Disposition: form-data; name=""%1""", ПолеФормы.Ключ));
	
	Если ПолеФормы.Свойство("ТипMIME") Тогда
		Ждать ЗаписьДанныхФормы.ЗаписатьСтрокуАсинх("Content-Type: " + ПолеФормы.ТипMIME);
	КонецЕсли;
	Если ПолеФормы.Свойство("Кодировка") Тогда
		Ждать ЗаписьДанныхФормы.ЗаписатьСтрокуАсинх("Content-Transfer-Encoding: " + ПолеФормы.Файл.Кодировка);
	КонецЕсли;
	Ждать ЗаписьДанныхФормы.ЗаписатьСтрокуАсинх("");
	Ждать ЗаписьДанныхФормы.ЗаписатьСтрокуАсинх(ПолеФормы.Значение);
	
	Возврат Неопределено;
КонецФункции

Асинх Функция ДобавитьДанныеФормыФайл(ПолеФормы, ЗаписьДанныхФормы)
	СтрокаПоля = СтрШаблон("Content-Disposition: form-data; name=""%1""", ПолеФормы.Ключ);
	
	ИмяФайла = ?(ПолеФормы.Файл.Свойство("ИмяФайла"), ПолеФормы.Файл.ИмяФайла, ПолеФормы.Значение.Имя);
	Если НЕ ПустаяСтрока(ИмяФайла) Тогда
		СтрокаПоля = СтрШаблон("%1; filename=""%2""", СтрокаПоля, ИмяФайла);
	КонецЕсли;
	
	Ждать ЗаписьДанныхФормы.ЗаписатьСтрокуАсинх(СтрокаПоля);
	Если ПолеФормы.Файл.Свойство("ТипMIME") Тогда
		Ждать ЗаписьДанныхФормы.ЗаписатьСтрокуАсинх("Content-Type: " + ПолеФормы.Файл.ТипMIME);
	КонецЕсли;
	Если ПолеФормы.Файл.Свойство("Кодировка") Тогда
		Ждать ЗаписьДанныхФормы.ЗаписатьСтрокуАсинх("Content-Transfer-Encoding: " + ПолеФормы.Файл.Кодировка);
	КонецЕсли;
	Ждать ЗаписьДанныхФормы.ЗаписатьСтрокуАсинх("");
	Ждать ЗаписьДанныхФормы.ЗаписатьАсинх(Новый ДвоичныеДанные(ПолеФормы.Значение.ПолноеИмя));
	Ждать ЗаписьДанныхФормы.ЗаписатьСтрокуАсинх("");
	
	Возврат Неопределено;
КонецФункции
#КонецОбласти
