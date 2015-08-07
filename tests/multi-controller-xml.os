﻿
Перем юТест;
Перем Распаковщик;
Перем Лог;

Процедура Инициализация()
	
	ПутьКРаспаковщику = ОбъединитьПути(ТекущийСценарий().Каталог, "../src/unpack.os");
	ПодключитьСценарий(ПутьКРаспаковщику, "Распаковщик");
	
	ПодключитьСценарий(ОбъединитьПути(ТекущийСценарий().Каталог, "../src/cmd-builder.os"), "КомандныйФайл");
	
	Распаковщик = Новый Распаковщик;
	Лог = Логирование.ПолучитьЛог("oscript.app.gitsync");
	Лог.УстановитьУровень(УровниЛога.Отладка);
	
КонецПроцедуры

//////////////////////////////////////////////////////////////////////
// Юнит-тесты

Функция ПрочитатьТестовыеНастройки()
	ФайлНастроек = АбсолютныйПуть("testData\config.xml");
	ПрочитатьНастройкиИзФайла(ФайлНастроек);
	мНастройки.Вставить("ИдентификаторКонфига", "testID");
КонецФункции

Функция КаталогFixtures()
	Возврат ОбъединитьПути(ТекущийСценарий().Каталог, "fixtures");
КонецФункции

Процедура Тест_ДолженПрочитатьФайлНастроек() Экспорт
	
	ПрочитатьТестовыеНастройки();
	
	// глобальные настройки
	юТест.ПроверитьРавенство("server.com", мНастройки.ДоменПочтыДляGit);
	юТест.ПроверитьРавенство("1cv8.exe"  , мНастройки.ПутьКПлатформе83);
	юТест.ПроверитьРавенство("git"       , мНастройки.ПутьGit);
	
	// репозитарии
	юТест.ПроверитьРавенство(2, мНастройки.Репозитарии.Количество());
	
	юТест.ПроверитьРавенство("test", мНастройки.Репозитарии[0].Имя);
	юТест.ПроверитьРавенство("путь1", мНастройки.Репозитарии[0].КаталогВыгрузки);
	юТест.ПроверитьРавенство("адрес1", мНастройки.Репозитарии[0].GitURL);
	юТест.ПроверитьРавенство("каталог1", мНастройки.Репозитарии[0].КаталогХранилища1С);
	юТест.ПроверитьРавенство(мНастройки.ПутьGit, мНастройки.Репозитарии[0].ПутьGit);
	юТест.ПроверитьРавенство(мНастройки.ПутьКПлатформе83, мНастройки.Репозитарии[0].ПутьКПлатформе83);
	юТест.ПроверитьРавенство(мНастройки.ДоменПочтыДляGit, мНастройки.Репозитарии[0].ДоменПочтыДляGit);
	
	юТест.ПроверитьРавенство("test2", мНастройки.Репозитарии[1].Имя);
	юТест.ПроверитьРавенство("путь2", мНастройки.Репозитарии[1].КаталогВыгрузки);
	юТест.ПроверитьРавенство("адрес2", мНастройки.Репозитарии[1].GitURL);
	юТест.ПроверитьРавенство("каталог2", мНастройки.Репозитарии[1].КаталогХранилища1С);
	юТест.ПроверитьРавенство(мНастройки.ПутьGit, мНастройки.Репозитарии[1].ПутьGit);
	юТест.ПроверитьРавенство(мНастройки.ПутьКПлатформе83, мНастройки.Репозитарии[1].ПутьКПлатформе83);
	юТест.ПроверитьРавенство("gmail.com", мНастройки.Репозитарии[1].ДоменПочтыДляGit);
	
	// сервер
	юТест.ПроверитьРавенство("localhost" , мНастройки.Сервер);
	
КонецПроцедуры