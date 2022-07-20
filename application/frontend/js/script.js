const menuObject = {
    body: document.body,
    navMenu: document.getElementById('nav-menu'),
    menuToggle: document.getElementById('menu-toggle'),
    menuClose: document.getElementById('menu-close'),
}

const showMenu = () => {
    menuObject.menuToggle.addEventListener('click', () => {
        menuObject.navMenu.classList.add('show-menu')
        // alert('button clicked')
    })
}

const closeMenu = () => {
    menuObject.menuClose.addEventListener('click', () => {
        menuObject.navMenu.classList.remove('show-menu')
    })
}

showMenu();
closeMenu();