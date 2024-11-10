document.addEventListener('turbo:load', function () {
  let account = document.querySelector('#accountDropdown');
  account.addEventListener('click', function (event) {
    event.preventDefault();
    let menu = document.querySelector('.dropdown-menu');
    menu.classList.toggle('active');
  });
});
