
#include a_samp
#include mdialog
#include a_mysql
#include cef
#include sscanf
//
#define NAME_SERVER "Mode v0001"

//macros
#define function:%1(%2) 		forward %1(%2); public %1(%2)
#define LOGIN_BROWSER_ID  0x12346
#define isPlayerLogged(%0)  player_is_logged{%0}
#define setPlayerLogged(%0,%1)  player_is_logged{%0} = %1
#define getName(%0)  player[%0][name]
//Constant
const bool:PLAYER_OFFLINE = false,
    bool:PLAYER_ONLINE = true,
    MAX_PLAYER_PASSWORD = 21,
    MAX_CHAT_LENGTH = 128,
    NULL = 0,
    CEF = 1,
    STANDART = 2
;
//
new MySQL:mysql_connect_ID;
enum e_PLAYER_DATA
{
	ID,
	name[MAX_PLAYER_NAME],
	password[MAX_PLAYER_PASSWORD],
	mail[24],
    interface,
    gender,
	skin
};
new player[MAX_PLAYERS][e_PLAYER_DATA];
new player_is_logged[MAX_PLAYERS char];


main()
{
	print("\n--------------------------------------");
	print(" Регистрация с использованием CEF by FARADAY");
	print("--------------------------------------\n");
}

public OnGameModeInit()
{
	SetGameModeText(NAME_SERVER);
	AddPlayerClass(0, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0);

    //
    mysql_connect_ID = mysql_connect_file();
    if (!mysql_errno())
        print("SUCCESS: Подключение к базе данных успешно удалось!");
    else
        printf("FAIL: Подключение к базе данных не удалось (Ошибка: %d)", mysql_errno());

    mysql_query(mysql_connect_ID, "SET character_set_client = 'cp1251'", false);
    mysql_query(mysql_connect_ID, "SET character_set_results = 'cp1251'", false);
    mysql_query(mysql_connect_ID, "SET SESSION character_set_server='utf8'", false);
    mysql_set_charset("cp1251");
    //ff

	return 1;
}

function:OnCefInitialize(player_id, success) {
    if (success == 1) {
        cef_subscribe("pwd:try", "Login"); //подписываемся на событие которое вызывали в cef.js , затем передаем ее в паблик Login
        cef_subscribe("pwd:reg", "Register");
        cef_subscribe("login:name", "SetNameLoginWindow");
        return 1;
    }
    return 1;
}
function:OnCefBrowserCreated(player_id, browser_id, status_code) {
    if (browser_id == LOGIN_BROWSER_ID) {
        if (status_code != 200) {
            return;
        }
    }
}

function:ExitCef(player_id, const arguments[]) {

    SendClientMessage(player_id, -1, "Вы не ввели логин или пароль!");
    cef_focus_browser(player_id, LOGIN_BROWSER_ID, false);
    cef_hide_browser(player_id, LOGIN_BROWSER_ID, true);
    return 1;
}
public OnGameModeExit()
{
    mysql_close(mysql_connect_ID);
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
    SetSpawnInfo(playerid, 255, 0, 0, 0, 0, 1.0, -1, -1, -1, -1, -1, -1);
    SetPlayerCameraPos(playerid, -2824.941162, 1093.736572, 35.373271);
	SetPlayerCameraLookAt(playerid,-2823.666503, 1098.571044, 35.314678);
	SetPlayerPos(playerid,-2823.666503, 1098.571044,22.314678);
	for(new u; u < 24; u++)
		SendClientMessage(playerid, -1, " ");

    SetPVarInt(playerid, #login_form, 1);
    SpawnPlayer(playerid);
	return 1;
}

public OnPlayerConnect(playerid)
{

	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    cef_destroy_browser(playerid, LOGIN_BROWSER_ID);
    savePlayerData(playerid);
	resetPlayerData(playerid);
	return 1;
}

public OnPlayerSpawn(playerid)
{

    if(!isPlayerLogged(playerid) && !GetPVarInt(playerid, #login_form))
        return Kick(playerid);


    if(GetPVarInt(playerid, #login_form)) {
        SetPlayerCameraPos(playerid, -2824.941162, 1093.736572, 35.373271);
    	SetPlayerCameraLookAt(playerid,-2823.666503, 1098.571044, 35.314678);// положение камеры при регистрации
    	SetPlayerPos(playerid,-2823.666503, 1098.571044,22.314678);
        SetPlayerVirtualWorld(playerid, 1);
        GetPlayerName(playerid, player[playerid][name], MAX_PLAYER_NAME);
        new query_str[144];
        format(query_str, sizeof query_str, "SELECT * FROM `accounts` WHERE `player_name` = '%s'", getName(playerid));
        mysql_tquery(mysql_connect_ID, query_str, "FindPlayerInTable","i", playerid);
        DeletePVar(playerid, #login_form);
        return 1;
    }

    SetPlayerPos(playerid, 1108.9304,-1796.2502,16.5938);
    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);
    SetPlayerFacingAngle(playerid,  90.0);
    SetPlayerSkin(playerid, player[playerid][skin]);
    return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	return 1;
}


public OnPlayerText(playerid, text[])
{
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	return 1;
}


function:FindPlayerInTable(playerid) {

    new rows;
	cache_get_row_count(rows);

	if(!rows)
	   Dialog_Show(playerid, Dialog:SELECT_INTERFACE);
	else
	{
		cache_get_value_int(0, "interface", player[playerid][interface]);

        if(player[playerid][interface] == CEF)
            showInterface(playerid, 0);
        else if(player[playerid][interface] == STANDART)
            showInterface(playerid, 1);
        else
            Dialog_Show(playerid, Dialog:SELECT_INTERFACE);
	}
    return 1;
}



showInterface(playerid, res) {

    new query_str[49+MAX_PLAYER_NAME];
    format(query_str, sizeof query_str, "select * from `accounts` where `player_name` = '%s'", getName(playerid));

    if(!res) {
        mysql_tquery(mysql_connect_ID, query_str, "cef_FindPlayerInTable","i", playerid);
        player[playerid][interface] = CEF;
    } else {
        mysql_tquery(mysql_connect_ID, query_str, "dialog_FindPlayerInTable","i", playerid);
        player[playerid][interface] = STANDART;
    }
    return 1;
}


function:SetNameLoginWindow(playerid, const arg[]) {

    cef_emit_event(playerid, "login:name", CEFSTR(getName(playerid)));
    cef_emit_event(playerid, "login:player_status", CEFINT(GetPVarInt(playerid, #status_login)));
}

//Dialogs
DialogCreate:SELECT_INTERFACE(playerid)
{
    Dialog_Open(playerid, Dialog:SELECT_INTERFACE, DIALOG_STYLE_MSGBOX, "Выбор стиля интерфейса", "\n\n\
        Если у вас установлена библиотека CEF в корень игры,\n\
        вы можете использовать сторонние интерфейсы.\n\n\n\
        Если хотите использовать сторонние интерфейсы нажмите кнопку 'CEF'\n\
        Если вы хотите использовать стандартные интерфейсы, нажмите кнопку 'Стандарт'\n\n\nЕсли в дальнейшем вы захотите сменить интерфес, перейдите:\nМеню персонажа>Настройки>Интерфейс", "Стандарт", "CEF");
}
DialogResponse:SELECT_INTERFACE(playerid, response, listitem, inputtext[]) {
    SetPVarInt(playerid, #login_form, 0);
    showInterface(playerid, response);
}
DialogCreate:REGISTER(playerid)
{
    Dialog_Open(playerid, Dialog:REGISTER, DIALOG_STYLE_INPUT, "Регистрация нового пользователя", "Введите пароль для регистрации нового аккаунта:\n\n\nПримечание:\n\n{666666}- Пароль чувствителен к регистру.\n- Пароль должен содержать от 4 до 30 символов.\n- Пароль может содержать латинские/кириллические символы и цифры (aA-zZ, аА-яЯ, 0-9).", "Регистрация", "Выход");
}
DialogResponse:REGISTER(playerid, response, listitem, inputtext[]) {
    if(!response)
    {
        ShowPlayerDialog(playerid, NULL, DIALOG_STYLE_MSGBOX, "Оповещение", "{FFFFFF}Вы были кикнуты с сервера.\n{FF0000}Причина: Отказ от регистрации.\n{FFFFFF}Для выхода с сервера введите \"/q\" в чат", "Выход", "");
        return Kick(playerid);
    }
    if(!strlen(inputtext)) {
        SendClientMessage(playerid, -1, "Ошибка: Вы не можете продолжить регистрацию не введя пароль!");
        return Dialog_Show(playerid, Dialog:REGISTER);
    }
    else if(strlen(inputtext) < 4) {
        SendClientMessage(playerid, -1, "Ошибка: Пароль слишком короткий!");
        return Dialog_Show(playerid, Dialog:REGISTER);
    }
    else if(strlen(inputtext) > MAX_PLAYER_PASSWORD) {
        SendClientMessage(playerid, -1, "Ошибка: Пароль слишком длинный!");
        return Dialog_Show(playerid, Dialog:REGISTER);
    }
    for(new i = strlen(inputtext)-1; i != -1; i--)
    {
        switch(inputtext[i])
        {
            case '0'..'9', 'a'..'z', 'A'..'Z': continue;
            default:  {
                SendClientMessage(playerid, -1, "Ошибка: Пароль содержит недопустимые символы!");
                return Dialog_Show(playerid, Dialog:REGISTER);
            }
        }
    }
    player[playerid][password][0] = EOS;
    strins(player[playerid][password], inputtext, 0);

    Dialog_Open(playerid, Dialog:GENDER, DIALOG_STYLE_LIST, "Выберите пол вашего персонажа", "Мужской\nЖенский", "Принять", "Выход");

    return 1;
}
DialogResponse:GENDER(playerid, response, listitem, inputtext[]) {
    if(!response)
        return Kick(playerid);

    new str[72];

    format(str, sizeof str, "Сервер: Пол вашего персонажа: %s", (listitem == 1) ? ("Женский") : ("Мужской"));
    SendClientMessage(playerid, -1, str);

    player[playerid][gender] = listitem;
    player[playerid][skin] = listitem == 1 ? 90 : 97;

    createNewAccount(playerid, player[playerid][password], "test@list.ru");
    return 1;
}
DialogCreate:LOGIN(playerid)
{
    Dialog_Open(playerid, Dialog:LOGIN, DIALOG_STYLE_INPUT, "Авторизация", "{ffffff}\\cВведите пароль от аккаунта:\n\n", "Вход", "Выход");
}
DialogResponse:LOGIN(playerid, response, listitem, inputtext[]) {

    if(!response)
    {
        ShowPlayerDialog(playerid, NULL, DIALOG_STYLE_MSGBOX, "Оповещение", "{FFFFFF}Вы были кикнуты с сервера.\n{FF0000}Причина: Отказ от авторизации.\n{FFFFFF}Для выхода с сервера введите \"/q\" в чат", "Выход", "");
        return Kick(playerid);
    }
    if(!strlen(inputtext)) {
        SendClientMessage(playerid, -1, "Ошибка: {FFFFFF}Вы не можете продолжить авторизацию не введя пароль!");
        return Dialog_Show(playerid, Dialog:LOGIN);
    }
    for(new i = strlen(inputtext)-1; i != -1; i--) {
        switch(inputtext[i]) {
            case '0'..'9', 'а'..'я', 'a'..'z', 'А'..'Я', 'A'..'Z': continue;
            default: {
                SendClientMessage(playerid, -1, "Ошибка: {FFFFFF}Пароль не должен содержать запрещенных символов!");
                return Dialog_Show(playerid, Dialog:LOGIN);
            }
        }
    }
    if(!strcmp(player[playerid][password], inputtext))
    {
        new query_str[49+MAX_PLAYER_NAME];
        format(query_str, sizeof query_str, "SELECT * FROM `accounts` WHERE `player_name` = '%s'", getName(playerid));
        mysql_tquery(mysql_connect_ID, query_str, "uploadPlayerData","i", playerid);
    }
    else
    {
        switch(GetPVarInt(playerid, "WrongPassword"))
        {
            case 0: {
                SendClientMessage(playerid, -1, "Ошибка: {FFFFFF}Вы ввели неверный пароль! У Вас осталось 3 попытки.");
                Dialog_Show(playerid, Dialog:LOGIN);
            }
            case 1: {
                SendClientMessage(playerid, -1, "Ошибка: {FFFFFF}Вы ввели неверный пароль! У Вас осталось 2 попытки.");
                Dialog_Show(playerid, Dialog:LOGIN);
            }
            case 2: {
                SendClientMessage(playerid, -1, "Ошибка: {FFFFFF}Вы ввели неверный пароль! У Вас осталось 1 попытки.");
                Dialog_Show(playerid, Dialog:LOGIN);
            }
            case 3: {
                SendClientMessage(playerid, -1, "Ошибка: {FFFFFF}Вы ввели неверный пароль! У Вас осталась последняя попытка.");
                Dialog_Show(playerid, Dialog:LOGIN);
            }
            default:
            {
                ShowPlayerDialog(playerid, NULL, DIALOG_STYLE_MSGBOX, "Оповещение", "{FFFFFF}Вы были кикнуты с сервера.\n{FF0000}Причина: Превышен лимит попыток на ввод пароля.\n{FFFFFF}Для выхода с сервера введите \"/q\" в чат", "Выход", "");
                return Kick(playerid);
            }
        }
        SetPVarInt(playerid, "WrongPassword", GetPVarInt(playerid, "WrongPassword")+1);
    }
    return 1;
}
//============

function: dialog_FindPlayerInTable(playerid)
{
	new rows;
	cache_get_row_count(rows);

	if(!rows)
	    Dialog_Show(playerid, Dialog:REGISTER);
	else
	{
		Dialog_Show(playerid, Dialog:LOGIN);
		cache_get_value_name(0, "password", player[playerid][password], 31);
	}
	return 1;
}
function:cef_FindPlayerInTable(playerid)
{
    new rows;
    cache_get_row_count(rows);
    cef_create_browser(playerid, LOGIN_BROWSER_ID, "C://Users//youj33n//Desktop//CefRegistration//siteLogin//index.html", false, true);

    if(!rows) SetPVarInt(playerid, #status_login, 0);
    else {
        SetPVarInt(playerid, #status_login, 1);
        cache_get_value_name(0, "password", player[playerid][password], 31);
    }

}




function: Register(player_id, const arguments[]) {
        new login[MAX_PLAYER_NAME], pass[MAX_PLAYER_PASSWORD], mail_reg[24], gender_reg, skin_reg;
        sscanf(arguments, "p<,>s[24]s[24]s[42]dd", login, pass, mail_reg, gender_reg, skin_reg);

        player[player_id][gender] = gender_reg;
        player[player_id][skin] = skin_reg;
        strins(player[player_id][password], pass, 0);
        createNewAccount(player_id, pass, mail_reg);
        //
        SetTimerEx("hide_display", 4400, false, "d", player_id);

}

function: Login(player_id, const arguments[]) {
        new login[MAX_PLAYER_NAME], pass[MAX_PLAYER_PASSWORD];
        print(arguments);
        sscanf(arguments, "p<,>s[24]s[21]", login, pass);
        if(!strcmp(player[player_id][password], pass)) {

            new query_str[49+MAX_PLAYER_NAME];
            format(query_str, sizeof query_str, "SELECT * FROM `accounts` WHERE `player_name` = '%s'", getName(player_id));
            mysql_tquery(mysql_connect_ID, query_str, "uploadPlayerData","i", player_id);
            cef_emit_event(player_id, "login:accept", CEFINT(1));
            //скрываем браузер после затемнения
            SetTimerEx("hide_display", 4400, false, "d", player_id);


        } else {
            cef_emit_event(player_id, "error:msg", CEFSTR("Неверно введен пароль"));
        }
}

function: hide_display(playerid) {
    cef_emit_event(playerid, "pwd:login_succes", CEFINT(0)); //Закрываем форму
    cef_focus_browser(playerid, LOGIN_BROWSER_ID, false);
}


stock createNewAccount(playerid, pass[], mails[])
{
	new query_str[256];
    player[playerid][ID] = random(998999)+1000;
	format(query_str, sizeof(query_str), "insert into `accounts` (`player_name`, `password`, `id`, `mail`, `gender`, `skin`) VALUES ('%s', '%s', '%d', '%s', '%d', '%d')", getName(playerid), pass, player[playerid][ID], mails, player[playerid][gender], player[playerid][skin]);
	mysql_tquery(mysql_connect_ID, query_str, "", "");


	format(query_str, sizeof(query_str), "Сервер: Аккаунт %s - успешно зарегистрирован.", getName(playerid));
	SendClientMessage(playerid, -1, query_str);
    SendClientMessage(playerid, -1, "Сервер: Желаем Вам приятной игры!");

	SetTimerEx("spawn_player_login", 2000, false, "d", playerid);
	setPlayerLogged(playerid, PLAYER_ONLINE);
	return 1;
}

function: uploadPlayerData(playerid)
{

    cache_get_value_name_int(0, "id", player[playerid][ID]);
	cache_get_value_name(0, "password",player[playerid][password], MAX_PLAYER_PASSWORD);
    cache_get_value_name(0, "mail",player[playerid][mail], 24);
    cache_get_value_name_int(0,"gender",player[playerid][gender]);
    cache_get_value_name_int(0,"skin",player[playerid][skin]);

    new str[MAX_CHAT_LENGTH];
    format(str, sizeof str, "Сервер: %s вы успешно авторизовались!", getName(playerid));
	SendClientMessage(playerid, -1, str);

    if(player[playerid][interface] == CEF)
        SetTimerEx("spawn_player_login", 2000, false, "d", playerid);
    else
        SpawnPlayer(playerid);

    SetPVarInt(playerid, #login_form, 0);
    setPlayerLogged(playerid, PLAYER_ONLINE);
	return 1;
}



function:spawn_player_login(playerid) {
    SpawnPlayer(playerid);
}

stock savePlayerData(playerid)
{
    if(!isPlayerLogged(playerid))
        return 1;

    new query_string[512] = "UPDATE `accounts` SET";
    format(query_string, sizeof query_string, "%s `password` = '%s',", query_string, player[playerid][password]);
    format(query_string, sizeof query_string, "%s `gender` = '%d',", query_string, player[playerid][gender]);
    format(query_string, sizeof query_string, "%s `skin` = '%d',", query_string, player[playerid][skin]);
    format(query_string, sizeof query_string, "%s `interface` = '%d'",  query_string, player[playerid][interface]);
    format(query_string, sizeof query_string, "%s WHERE id = '%d'", query_string, player[playerid][ID]);
  	mysql_tquery(mysql_connect_ID, query_string,  "", "");
    return 1;
}
stock resetPlayerData(playerid)
{
	player[playerid][ID] = -1;
	player[playerid][name][0] = EOS;
	player[playerid][password][0] = EOS;
	return 1;
}
