#Использовать opm
#Использовать gitrunner

Перем ВнутреннийМенеджерУстановкиПакетов;
Перем ИндексУстановленныхПлагинов;
Перем Лог;

Функция ПолучитьУстановленныеПлагины() Экспорт

	Возврат ИндексУстановленныхПлагинов;
	
КонецФункции

Функция ВывестиИнформациюОПлагине(Знач ОписаниеПлагина) Экспорт
	
	Сообщить(СтрШаблон("%1 - v %2", ОписаниеПлагина.ИмяПакета, ОписаниеПлагина.Версия));
	
КонецФункции

Процедура ОбновитьЗагрузчикБиблиотекВКаталогеПлагинов()

	КаталогиПлагинов = НайтиФайлы(НастройкиGitsync.ПолучитьКаталогПлагинов(), ПолучитьМаскуВсеФайлы(), Ложь); 

	ШапкаЗагрузчика = "//////////////////////////////////////////////////////
	|// ДАННЫЙ ФАЙЛ ФОРМИРУЕТСЯ АВТОМАТИЧЕСКИ            //
	|// ВСЕ ВНЕСЕННЫЕ ИЗМЕНЕНИЯ В РУЧНУЮ БУДУТ ПОТЕРЯНЫ  //
	|//////////////////////////////////////////////////////";


	ШаблонСтрокиИмпортаПлагина = "
	|///////////////////////////////////
	|// ИМПОРТ БИБЛИОТЕКИ ПЛАГИНА ""%1""
	|#Использовать ""./%1""
	|///////////////////////////////////";

	ТекстИмпортаБиблиотек = "
	|";

	Для каждого Каталоги Из КаталогиПлагинов Цикл
	
			Если Не Каталоги.ЭтоКаталог() Тогда
				Продолжить
			КонецЕсли;
			
			ТекстИмпортаБиблиотек = ТекстИмпортаБиблиотек + СтрШаблон(ШаблонСтрокиИмпортаПлагина, Каталоги.Имя) + Символы.ПС;
	
	КонецЦикла;
		
	ТекстОтказаОтСтандартнойЗагруки = "
	|Процедура ПриЗагрузкеБиблиотеки(Путь, СтандартнаяОбработка, Отказ)
	|
	|	СтандартнаяОбработка = Ложь;
	|
	|КонецПроцедуры
	|";
	
	ИтоговыйТекстФайлаЗагрузкиБиблиотек = ШапкаЗагрузчика + ТекстИмпортаБиблиотек + ТекстОтказаОтСтандартнойЗагруки;

	ЗаписатьФайлЗагрузкиПлагинов(ИтоговыйТекстФайлаЗагрузкиБиблиотек);

КонецПроцедуры

Процедура ЗаписатьФайлЗагрузкиПлагинов(ТекстОбработчика)
	
	ПутьКФайлуЗагрузчику = ОбъединитьПути(НастройкиGitsync.ПолучитьКаталогПлагинов(), "package-loader.os");
	Лог.Отладка("ПутьКФайлуЗагрузчику = <%1>", ПутьКФайлуЗагрузчику);
	Попытка
		Запись = Новый ЗаписьТекста(ПутьКФайлуЗагрузчику, "utf-8");
		Запись.ЗаписатьСтроку(ТекстОбработчика);
		Запись.Закрыть();
	Исключение
		Если Запись <> Неопределено Тогда
			ОсвободитьОбъект(Запись);
		КонецЕсли;
		ВызватьИсключение;
	КонецПопытки;

КонецПроцедуры

Процедура ОбновитьИндексУстановленныхПлагинов() Экспорт

	Лог.Отладка("Обновление индекса плагина");
	ИндексУстановленныхПлагинов = Новый Соответствие;

	КаталогиПлагинов = НайтиФайлы(НастройкиGitsync.ПолучитьКаталогПлагинов(), ПолучитьМаскуВсеФайлы(), Ложь); 

	Для каждого Каталоги Из КаталогиПлагинов Цикл
		
		Если Не Каталоги.ЭтоКаталог() Тогда
			Продолжить
		КонецЕсли;
		
		ЗагрузитьПлагин(Каталоги.ПолноеИмя);

	КонецЦикла;

	Лог.Отладка("В индекс плагинов добавлено <%1> плагинов", ИндексУстановленныхПлагинов.Количество());


КонецПроцедуры

Процедура ЗагрузитьПлагин(Путь)

	//Сообщить("Загружаю плагин");
	Лог.Отладка("
	|Загружаю плагин " + Путь);	

	ФайлМанифеста = Новый Файл(ОбъединитьПути(Путь, "lib.config"));
	
	Если ФайлМанифеста.Существует() Тогда
		Лог.Отладка("Обрабатываем по манифесту");

		СтандартнаяОбработка = Ложь;
		ДобавитьКлассыПлагинов(ФайлМанифеста.ПолноеИмя, Путь);
	Иначе
		Лог.Информация("Плагины из каталога <%1> не могут быть загружены - не найден файл <lib.config>");
	КонецЕсли;

КонецПроцедуры

Процедура ДобавитьКлассыПлагинов(Знач Файл, Знач Путь)
	
	Чтение = Новый ЧтениеXML;
	Чтение.ОткрытьФайл(Файл);
	Чтение.ПерейтиКСодержимому();
	
	Если Чтение.ЛокальноеИмя <> "package-def" Тогда
		Чтение.Закрыть();
		Возврат;
	КонецЕсли;
	
	Пока Чтение.Прочитать() Цикл
		
		Если Чтение.ТипУзла = ТипУзлаXML.Комментарий Тогда

			Продолжить;

		КонецЕсли;

		Если Чтение.ТипУзла = ТипУзлаXML.НачалоЭлемента Тогда
		
			Если Чтение.ЛокальноеИмя = "class" Тогда
				ФайлКласса = Новый Файл(Путь + "/" + Чтение.ЗначениеАтрибута("file"));
				Если ФайлКласса.Существует() и ФайлКласса.ЭтоФайл() Тогда
					Идентификатор = Чтение.ЗначениеАтрибута("name");
					Если Не ПустаяСтрока(Идентификатор) Тогда
						// ДобавитьКласс(ФайлКласса.ПолноеИмя, Идентификатор);
						ДобавитьПлагинВИндекс(Идентификатор);
					КонецЕсли;
				Иначе
					ВызватьИсключение "Не найден файл " + ФайлКласса.ПолноеИмя + ", указанный в манифесте";
				КонецЕсли;
				
				Чтение.Прочитать(); // в конец элемента

			КонецЕсли;
			
		КонецЕсли;
		
	КонецЦикла;
	
	Чтение.Закрыть();
	
КонецПроцедуры

Процедура ДобавитьПлагинВИндекс(Знач ИмяКлассаПлагина)
	
	Лог.Отладка("Добавляю плагин <%1> в индекс плагинов", ИмяКлассаПлагина);

	Попытка
		КлассПлагина = Новый (ИмяКлассаПлагина);
	Исключение
		Лог.Отладка("Ошибка добавления плагина <%1> в индекс плагинов. Класс <%1> не найден", ИмяКлассаПлагина);
		Возврат;
	КонецПопытки;

	ОписаниеПлагина = Неопределено;

	Если ЭтоКлассПлагина(КлассПлагина, ОписаниеПлагина) Тогда
		МетаданныеПлагина = НовыеМетаданныеПлагина(ИмяКлассаПлагина, ОписаниеПлагина);
		ИндексУстановленныхПлагинов.Вставить(МетаданныеПлагина.ИмяПлагина, МетаданныеПлагина);
	КонецЕсли;

КонецПроцедуры

Функция НовыеМетаданныеПлагина(Знач ИмяКлассаПлагина, Знач ОписаниеПлагина)
	
	Лог.Отладка("Формирую метаданные плагина <%1>", ИмяКлассаПлагина);

	Возврат Новый Структура("Класс, ИмяПлагина, Описание", ИмяКлассаПлагина, ОписаниеПлагина.ИмяПакета, ОписаниеПлагина);
	
КонецФункции

Функция ЭтоКлассПлагина(Знач КлассПлагина, ОписаниеПлагина)

	Попытка
		ОписаниеПлагина = КлассПлагина.ОписаниеПлагина();
		Возврат Истина;
	Исключение
		Возврат Ложь;
	КонецПопытки;
	
КонецФункции

Функция ПолучитьВключенныеПлагины() Экспорт

	ВключенныеПлагины = Новый Соответствие;

	ИмяФайла = ОбъединитьПути(НастройкиGitsync.ПолучитьКаталогGitsync(), ".enabled-plugins");
	ФайлАктивныхПлагинов= Новый Файл(ИмяФайла);

	Если Не ФайлАктивныхПлагинов.Существует() Тогда
		Возврат ВключенныеПлагины;
	КонецЕсли;

	РезультатЧтения = ПрочитатьФайл(ИмяФайла);

	МассивПлагинов = СтрРазделить(РезультатЧтения, Символы.ПС);

	Для каждого Плагин Из МассивПлагинов Цикл
		ВключенныеПлагины.Вставить(Плагин, Истина);
	КонецЦикла;

	Возврат ВключенныеПлагины;

КонецФункции

Процедура ВключитьПлагины(Знач ВключенныеПлагины) Экспорт

	ИмяФайла = ОбъединитьПути(НастройкиGitsync.ПолучитьКаталогGitsync(), ".enabled-plugins");

	Запись = Новый ЗаписьТекста(ИмяФайла);
	Для каждого ИмяПлагина Из ВключенныеПлагины Цикл
		Запись.ЗаписатьСтроку(ИмяПлагина.Ключ);
	КонецЦикла;

	Запись.Закрыть();

КонецПроцедуры

Функция ПрочитатьФайл(Знач ИмяФайла)
	
	Чтение = Новый ЧтениеТекста(ИмяФайла, КодировкаТекста.UTF8);
	Рез  = Чтение.Прочитать();
	Чтение.Закрыть();
	
	Возврат Рез;

КонецФункции // ПрочитатьФайл()


Функция ПолучитьМенеджерУстановкиПакетов() 

	Если ВнутреннийМенеджерУстановкиПакетов = Неопределено Тогда
		ВнутреннийМенеджерУстановкиПакетов = Новый МенеджерУстановкиПакетов(РежимУстановкиПакетов.Локально,
							 НастройкиGitsync.ПолучитьКаталогПлагинов(),
							 НастройкиGitsync.ПолучитьКаталогЗависимостей());
							 ВнутреннийМенеджерУстановкиПакетов.УстановитьЦелевойКаталог(НастройкиGitsync.ПолучитьКаталогПлагинов());
	КонецЕсли;

	Возврат ВнутреннийМенеджерУстановкиПакетов;
	
КонецФункции

Функция УстановитьФайлПлагин(Знач ПутьКПлагину) Экспорт
	
	ФайлПлагина = Новый Файл(ПутьКПлагину);

	Если Не ФайлПлагина.Существует() Тогда
		Лог.КритичнаяОшибка("Плагин не установлен. Файл <%1> плагина не найден", ПутьКПлагину);
		ВызватьИсключение "";
	КонецЕсли;

	ПутьКФайлуПлагина = ФайлПлагина.ПолноеИмя;

	УстановщикПлагинов = ПолучитьМенеджерУстановкиПакетов();
	УстановщикПлагинов.УстановитьПакетИзАрхива(ПутьКПлагину);

	ОбновитьЗагрузчикБиблиотекВКаталогеПлагинов();

КонецФункции

Функция УстановитьПлагинСGitHub(Знач URL, Знач ТегВерсия = Неопределено) Экспорт
	
	

КонецФункции


Функция ПрочитатьОписаниеПлагина(Знач ПутьКФайлуПлагина) Экспорт

	Описание = Новый ОписаниеПакета();

	ПутьКМанифесту = ОбъединитьПути(ПутьКФайлуПлагина, "packagedef");
	
	Файл_Манифест = Новый Файл(ПутьКМанифесту);
	Если Файл_Манифест.Существует() Тогда
		Контекст = Новый Структура("Описание", Описание);
        ЗагрузитьСценарий(ПутьКМанифесту, Контекст);
    КонецЕсли;		

	Возврат Описание.Свойства();

КонецФункции

Процедура УстановитьПакетИзАрхива(Знач ФайлАрхива) Экспорт
	
	
КонецПроцедуры

Лог = Логирование.ПолучитьЛог("oscript.app.gitsync_plugins");

ИндексУстановленныхПлагинов = Новый Соответствие;
Лог.УстановитьУровень(УровниЛога.Отладка);
