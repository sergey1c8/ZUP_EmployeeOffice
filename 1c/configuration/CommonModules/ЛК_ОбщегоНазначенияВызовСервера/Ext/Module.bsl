﻿#Область ПрограммныйИнтерфейс

Процедура ПриНачалеРаботыСистемы() Экспорт 	
	
	Если РольДоступна("ЛК_Администратор") Тогда
		
		Если Не ЗначениеЗаполнено(ЛК_РаботаСФункциямиКлиентСервер.Результат(ЛК_ОбменДаннымиПовтИсп.НастройкиСервиса()).АдресСервера) Тогда
			Возврат;
		КонецЕсли; 

		//Считаем что это инициализация
		НайденныйЭлемент = Справочники.ЛК_СтатусыЗаявокНаСправки.НайтиПоКоду(2);
		Если Не ЗначениеЗаполнено(НайденныйЭлемент) Тогда

			НовыйЭлемент = Справочники.ЛК_СтатусыЗаявокНаСправки.СоздатьЭлемент();
			НовыйЭлемент.Наименование = "Новый";
			НовыйЭлемент.Код = 2;
			НовыйЭлемент.Записать();
			
			НовыйЭлемент = Справочники.ЛК_СтатусыЗаявокНаСправки.СоздатьЭлемент();
			НовыйЭлемент.Наименование = "В работе";
			НовыйЭлемент.Код = 3;
			НовыйЭлемент.Записать();

			НовыйЭлемент = Справочники.ЛК_СтатусыЗаявокНаСправки.СоздатьЭлемент();
			НовыйЭлемент.Наименование = "Отменена";
			НовыйЭлемент.Код = 4;
			НовыйЭлемент.Записать();
			
			НовыйЭлемент = Справочники.ЛК_СтатусыЗаявокНаСправки.СоздатьЭлемент();
			НовыйЭлемент.Наименование = "Выполнена";
			НовыйЭлемент.Код = 5;
			НовыйЭлемент.Записать();
			
			НовыйЭлемент = Справочники.ЛК_ТипыСправок.СоздатьЭлемент();
			НовыйЭлемент.Наименование = "НДФЛ";
			НовыйЭлемент.Код = 1;
			НовыйЭлемент.Записать();
			
			Выборка = Справочники.ВидыИспользованияРабочегоВремени.Выбрать();
			Пока Выборка.Следующий() Цикл 
				ЛК_ОбработкаСобытийСервер.ЗарегистрироватьЗаписьСсылочногоОбъекта(Выборка.Ссылка, Истина);
			КонецЦикла;	
			
			Выборка = Справочники.ГрафикиРаботыСотрудников.Выбрать();
			Пока Выборка.Следующий() Цикл 
				
				ЛК_ОбработкаСобытийСервер.ЗарегистрироватьЗаписьСсылочногоОбъекта(Выборка.Ссылка, Истина);
				
				Запрос = Новый Запрос;
				Запрос.Текст =" 
				|ВЫБРАТЬ РАЗЛИЧНЫЕ
				|	ГрафикиРаботыПоВидамВремени.Месяц КАК Месяц,
				|	ГрафикиРаботыПоВидамВремени.ГрафикРаботы КАК ГрафикРаботы
				|ИЗ
				|	РегистрСведений.ГрафикиРаботыПоВидамВремени КАК ГрафикиРаботыПоВидамВремени
				|ГДЕ
				|	ГрафикиРаботыПоВидамВремени.ГрафикРаботы = &ГрафикРаботы
				|
				|УПОРЯДОЧИТЬ ПО
				|	Месяц
				|";
				Запрос.Параметры.Вставить("ГрафикРаботы", Выборка.Ссылка); 
				
				ВыборкаЗапроса =  Запрос.Выполнить().Выбрать();
				
				ТипОбъекта	= ЛК_ОбменДаннымиПовтИсп.ТипыОбъектов().РСНЗ;
				ИмяОбъекта = "ГрафикиРаботыПоВидамВремени";

				
				Пока ВыборкаЗапроса.Следующий() Цикл 
					
					Структура = Новый Структура;
					Структура.Вставить("ГрафикРаботы",     Выборка.Ссылка);
					Структура.Вставить("Месяц",            ВыборкаЗапроса.Месяц);
					
					ДанныеJSON = ЛК_РаботаСJSONСервер.ЗаписьJSON(Структура);	
					
					ХешированиеДанных  = Новый ХешированиеДанных (ХешФункция.CRC32);
					ХешированиеДанных.Добавить(ДанныеJSON);
					ХешСумма = ХешированиеДанных.ХешСумма;
					
					РегистрыСведений.ЛК_ОчередьОбменаСЛКПроизвольнымиДанными.ЗарегистрироватьДобавлениеОбъекта(ТипОбъекта, ИмяОбъекта, ХешСумма, ДанныеJSON);
					
				КонецЦикла;
				
			КонецЦикла;	
			
			Запрос = Новый Запрос;
			Запрос.Текст = "ВЫБРАТЬ
							|	Организации.Ссылка КАК Ссылка
							|ИЗ
							|	Справочник.Организации КАК Организации";
						
			Выборка = Запрос.Выполнить().Выбрать();
			Пока Выборка.Следующий() Цикл
				ЛК_ОбработкаСобытийСервер.ЗарегистрироватьЗаписьСсылочногоОбъекта(Выборка.Ссылка, Истина);
			КонецЦикла;
			
			Запрос.Текст = "ВЫБРАТЬ
			               |	ПодразделенияОрганизаций.Ссылка КАК Ссылка
			               |ИЗ
			               |	Справочник.ПодразделенияОрганизаций КАК ПодразделенияОрганизаций";
			
	
			Выборка = Запрос.Выполнить().Выбрать();
			Пока Выборка.Следующий() Цикл
				ЛК_ОбработкаСобытийСервер.ЗарегистрироватьЗаписьСсылочногоОбъекта(Выборка.Ссылка, Истина);
			КонецЦикла;
			
			Запрос = Новый Запрос;
			Запрос.Текст = "ВЫБРАТЬ
			               |	Должности.Ссылка КАК Ссылка
			               |ИЗ
			               |	Справочник.Должности КАК Должности";
	
			Выборка = Запрос.Выполнить().Выбрать();
			Пока Выборка.Следующий() Цикл
				ЛК_ОбработкаСобытийСервер.ЗарегистрироватьЗаписьСсылочногоОбъекта(Выборка.Ссылка, Истина);
			КонецЦикла;

		КонецЕсли;	
		
	КонецЕсли;
	
КонецПроцедуры	

#КонецОбласти
