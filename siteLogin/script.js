

let getSkin = -1;


let showReg = () => {
  resetError();
  document.getElementById('login').style.display = 'none';
  document.getElementById('register').style.display = 'block';
  document.getElementById('cc-selector').style.display = 'none';
  document.getElementById('cc-selector-fem').style.display = 'none';}


let showLogin = () => {
    resetError();
    document.getElementById('login').style.display = 'block';
    document.getElementById('register').style.display = 'none';
    document.getElementById('cc-selector').style.display = 'none';
    document.getElementById('cc-selector-fem').style.display = 'none';
    //document.getElementById('bodyd').style.display = 'none';
}

let resetWindow = () => {
    document.getElementById('login').style.display = 'none';
    document.getElementById('register').style.display = 'none';
    document.getElementById('cc-selector').style.display = 'none';
    document.getElementById('cc-selector-fem').style.display = 'none';
    document.getElementById('windowr').style.display = 'none';
    document.getElementById('radios').style.display = 'none';
    document.getElementById('error').style.display = 'none';
    document.getElementsByClassName('form')[0].style.display = 'none';

}

cef.emit("login:player_status")
cef.on('login:player_status', (response) => {

    if(response == 1) showLogin()
    else showReg()

})


function loginAttempt(){
    const login = document.getElementById('log-login').placeholder;
    const password = document.getElementById('log-password').value;
    resetError();


    if(!password || password.length < 6){
        return showError('Введите Пароль');
    }



    let attemp = login + ',' + password;
    cef.emit('pwd:try', attemp);
}
function screenDimming() {
    document.getElementById('bodyd').style.backgroundColor = ''
    document.getElementById('bodyd').style.transition = '2s'
}



function registerAttempt(){

    const login = document.getElementById('reg-login').placeholder;
    const mail = document.getElementById('reg-mail').value;
    const password = document.getElementById('reg-password').value;
    const passwordConfirm = document.getElementById('reg-password-confirm').value;
    const gender_female = document.getElementById('female');
    const gender_male = document.getElementById('male');

    resetError();

    let reg = /^([A-Za-z0-9_\-\.])+\@([A-Za-z0-9_\-\.])+\.([A-Za-z]{2,4})$/;

    if(!mail || mail.length < 3 || reg.test(mail) == false){
        return showError('Введите корректный email');
    }
    let pass_r =/^[A-Za-z0-9]{6,18}$/;
    if(pass_r.test(password) == false)
        return showError('Пароль может из состоять из латинских букв и цифр (Содержать от 6 до 18 символов)')

    if(password != passwordConfirm){
        return showError('Пароли не совпадают');
    }

    if(gender_male.checked == false && gender_female.checked == false)
        return showError('Выбери пол персонажа');


    if(getSkin == -1)
        return showError('Выбери скин персонажа');

    const skin = [6, 22, 48, 56, 69, 41];

    const gender = gender_male.checked == false ? 1 : 2;
    let attemp = login + ',' + password + ',' + mail + ',' + gender  + ',' + skin[getSkin-1];
    cef.emit('pwd:reg', attemp);
    resetWindow()
    document.getElementById('bodyd').style.backgroundColor = '#000'
    document.getElementById('bodyd').style.transition = '0.5s'
    setTimeout(screenDimming, 4000);
}


cef.on('error:msg', (response) => {
    showError(response)
});

cef.on('login:accept', (response) => {
    if(response == 1) {
        resetWindow();
        //
        cef.set_focus(false);
        document.getElementById('bodyd').style.backgroundColor = '#000'
        document.getElementById('bodyd').style.transition = '0.5s'
        setTimeout(screenDimming, 4000);
    }

});

cef.emit("login:name")
cef.on('login:name', (response) => {


    document.getElementById('reg-login').placeholder = response;
    document.getElementById('reg-login').readOnly = true;
    document.getElementById('log-login').placeholder = response;
    document.getElementById('log-login').readOnly = true;

});

function onExitClick(event) {
    //serverResponse.innerText = "Close";
    cef.emit('pwd:exit_forms');
}
cef.on('pwd:login_succes', (response) => {

    if (response == 1) {
        cef.set_focus(false);
        cef.hide(true);
        cef.emit('pwd:exit_forms');
    } else {
        //serverResponse.innerText = "Вы успешно авторизовались!";
        cef.hide(true); //скрываем браузер
        cef.set_focus(false); //убираем фокусирование с браузера
        resetWindow()
    }
});

function showError(message){
    const errorBlock = document.getElementById('error');
    errorBlock.innerText = message;
    errorBlock.style.display = 'block';

    const errorBlock2 = document.getElementById('error_reg');
    errorBlock2.innerText = message;
    errorBlock2.style.display = 'block';
}

function resetError(){
    const errorBlock = document.getElementById('error');
    errorBlock.innerText = 'message';
    errorBlock.style.display = 'none';

    const errorBlock2 = document.getElementById('error_reg');
    errorBlock2.innerText = 'message';
    errorBlock2.style.display = 'none';
}



function clickgender(res) {
    if(res == 1) {
        document.querySelector('#cc-selector-fem').style.display = 'none';
        document.querySelector('#cc-selector').style.display = 'block';
    } else {
        document.querySelector('#cc-selector-fem').style.display = 'block';
        document.querySelector('#cc-selector').style.display = 'none';
    }
}

function isCheckedSkinGender(res) {
   return getSkin = res;
}
