#Использовать "../../../plugins"

Перем КаталогУстановкиGitSync;
Перем КаталогПлагинов;
Перем КаталогЗависимостей;

Функция ПолучитьКаталогGitsync() Экспорт
	
	Если КаталогУстановкиGitSync = Неопределено Тогда
		
		КаталогУстановкиGitSync = Новый Файл(ОбъединитьПути(ТекущийСценарий().Каталог, "..", "..", "..")).ПолноеИмя;

	КонецЕсли;
	
	Возврат КаталогУстановкиGitSync;

КонецФункции

Функция ПолучитьКаталогПлагинов() Экспорт
	
	Если КаталогПлагинов = Неопределено Тогда
		
		КаталогПлагинов = ОбъединитьПути(ПолучитьКаталогGitsync(), "plugins");

	КонецЕсли;
	
	Возврат КаталогПлагинов;

КонецФункции

Функция ПолучитьКаталогЗависимостей() Экспорт
	
	Если КаталогЗависимостей = Неопределено Тогда
		
		КаталогЗависимостей = ОбъединитьПути(ПолучитьКаталогGitsync(), "oscript_modules");

	КонецЕсли;
	
	Возврат КаталогЗависимостей;

КонецФункции

