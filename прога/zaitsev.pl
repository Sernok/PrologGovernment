:- use_module(library(pce)).
:- encoding(utf8).

% начальная директория
:- working_directory(_, 'C:/Users/HIPER/OneDrive/Desktop/курсач/курсовые/курсовая пролог/Government').

% --- Приветственный экран с изображением ---
welcome :-
    new(Window, dialog('Добро пожаловать')),
    send(Window, size, size(800, 700)),

    % Заголовок
    send(Window, append, label(subtitle, ''), below),

    % Размер изображения
    get(Window, size, Size),
    get(Size, width, WindowWidth),
    ImgWidth is (WindowWidth),
    ImgHeight is 800,

    % Загрузка изображения
    (   catch(new(Bitmap, bitmap('startpage.jpg')), _, fail)
    ->  new(Pic, picture),
        send(Pic, display, Bitmap, point(0, 0)),
        send(Pic, size, size(ImgWidth, ImgHeight)),
        send(Window, append, Pic, below)
    ;   send(Window, append, label(error, 'Изображение не найдено.'), below)
    ),

    % Кнопки
    send(Window, append, new(BtnGroup, dialog_group(buttons))),
    send(Window, append, label(spacer, ''), below),  % <-- пустая строка

    new(StartBtn, button('Начать', message(Window, return, start))),
    new(ExitBtn,  button('Выход', message(Window, return, cancel))),
    send(BtnGroup, append, StartBtn),
    send(BtnGroup, append, ExitBtn),
    send(Window, append, BtnGroup, below),

    send(Window, default_button, StartBtn),

    get(Window, confirm, Result),
    free(Window),
    (   Result == cancel ; Result == @nil
    ->  halt
    ;   true
    ).


% --- Основные предметные области ---
area('исполнительная').
area('законодательная').
area('судебная').

% --- Органы в зависимости от области ---
organ('исполнительная', 'Правительство').
organ('исполнительная', 'Министерство внутренних дел').
organ('законодательная', 'Государственная Дума').
organ('законодательная', 'Совет Федерации').
organ('судебная', 'Верховный суд').
organ('судебная', 'Конституционный суд').


% --- Получение ФИО ---
get_name(Name) :-
    repeat,
    new(D, dialog('Приветствие')),
    send(D, append, label(prompt, 'Как вас зовут?')),
    send(D, append, new(TI, text_item(name))),
    send(D, append, button(ok, message(D, return, ok))),
    send(D, append, button(cancel, message(D, return, cancel))),
    send(D, default_button, ok),
    get(D, confirm, Result),
    (   Result == ok
    ->  get(TI, selection, Name),
        (Name == '' ->
            send(@display, inform, 'Введите имя'),
            free(D),
            fail
        ;   free(D),
            format('Пользователь ввел имя: ~w~n', [Name]),
            !
        )
    ;   free(D),
        halt
    ).


% --- Выбор области ---
get_area(Area) :-
    new(D, dialog('Предметная область')),
    send(D, append, label(prompt, 'Выберите предметную область:')),
    new(Menu, menu(area, cycle)),
    forall(area(A), send(Menu, append, A)),
    send(D, append, Menu),
    send(D, append, button(ok, message(D, return, Menu?selection))),
    send(D, append, button(cancel, message(D, return, cancel))),
    send(D, default_button, ok),
    get(D, confirm, Selection),
    (   Selection == cancel
    ->  free(D),
        halt
    ;   (Selection == @nil
        ->  send(@display, inform, 'Выберите предметную область.'),
            free(D),
            fail
        ;   Area = Selection,
            free(D),
            format('Пользователь выбрал область: ~w~n', [Area]), % Вывод в консоль
            !
        )
    ).

% --- Выбор органа ---
get_organ(Area, Organ) :-
    new(D, dialog('Выбор органа')),
    send(D, append, label(prompt, 'Выберите орган:')),
    new(Menu, menu(organ, cycle)),
    forall(organ(Area, Org), send(Menu, append, Org)),
    send(D, append, Menu),
    send(D, append, button(ok, message(D, return, Menu?selection))),
    send(D, append, button(cancel, message(D, return, cancel))),
    send(D, default_button, ok),
    get(D, confirm, Selection),
    (   Selection == cancel
    ->  free(D),
        halt
    ;   (Selection == @nil
        ->  send(@display, inform, 'Выберите орган.'),
            free(D),
            fail
        ;   Organ = Selection,
            free(D),
            format('Пользователь выбрал орган: ~w~n', [Organ]), % Вывод в консоль
            !
        )
    ).

% --- Город и область ---
get_location(Region, City) :-
    repeat,
    new(D, dialog('Местоположение')),
    send(D, append, label(prompt, 'Введите регион:')),
    send(D, append, new(RItem, text_item(region))),
    send(D, append, label(prompt2, 'Введите город:')),
    send(D, append, new(CItem, text_item(city))),
    send(D, append, button(ok, message(D, return, ok))),
    send(D, append, button(cancel, message(D, return, cancel))), % Добавлена кнопка отмены
    send(D, default_button, ok),
    get(D, confirm, Result),
    (   Result == ok
    ->  get(RItem, selection, Region),
        get(CItem, selection, City),
        (   (Region = '' ; City = '') % Проверка на пустые строки
        ->  send(@display, inform, 'Пустая строка региона или города, повторите ввод'),
            free(D),
            fail
        ;   free(D),
            format('Пользователь ввел регион: ~w и город: ~w~n', [Region, City]), % Вывод в консоль

            ! % Успешное завершение
        )
    ;   free(D),
        !, % Принудительный выход при отмене
        halt
    ).

get_date(Date) :-
    repeat,
    new(D, dialog('Введите дату приёма')),
    send(D, append, new(TI, text_item(date, '2025-06-15'))),
    send(D, append, button(ok, message(D, return, TI?selection))),
    send(D, default_button, ok),
    get(D, confirm, Input),
    send(D, destroy),
    (   catch(parse_time(Input, iso_8601, Timestamp), _, fail),
        get_time(Now),
        Timestamp >= Now
    ->  Date = Input,
        format('Пользователь ввел дату: ~w~n', [Date]), % Вывод в консоль
        !;   
        send(@display, inform,
             'Некорректная дата! Убедитесь, что она в формате ГГГГ-ММ-ДД и не раньше текущей.'),
        fail
    ).

% --- Финальное окно вывода ---
show_summary(Name, Area, Organ, Region, City, Date) :-
    new(D, dialog('Итоговая информация')),
    format(atom(Summary),
        'ФИО: ~w~nОбласть: ~w~nОрган: ~w~nРегион: ~w~nГород: ~w~nДата приёма: ~w',
        [Name, Area, Organ, Region, City, Date]),
    send(D, append, label(info, Summary)),
    send(D, append, button(ok, message(D, destroy))),
    send(D, open),
     % Вывод итоговой информации в консоль
    format('~n=== Итоговая информация ===~n'),
    format('ФИО: ~w~n', [Name]),
    format('Область: ~w~n', [Area]),
    format('Орган: ~w~n', [Organ]),
    format('Регион: ~w~n', [Region]),
    format('Город: ~w~n', [City]),
    format('Дата приёма: ~w~n', [Date]).

% --- Главный запуск ---
start :-
    welcome(),
    get_name(Name),
    get_area(Area),
    get_organ(Area, Organ),
    get_location(Region, City),
    get_date(Date),
    show_summary(Name, Area, Organ, Region, City, Date).