const menu = {
    body: document.body,
    navMenu: document.getElementById('nav-menu'),
    menuToggle: document.getElementById('menu-toggle'),
    menuClose: document.getElementById('menu-close'),
    navLink: document.querySelectorAll('#nav-link')
}

const showMenu = () => {
    menu.menuToggle.addEventListener('click', () => {
        menu.navMenu.classList.add('show-menu')
        // alert('button clicked')
    })
}

const closeMenu = () => {
    menu.menuClose.addEventListener('click', () => {
        menu.navMenu.classList.remove('show-menu')
    })
}

const navLinkCloseMenu = () => {
    menu.navLink.forEach(n => n.addEventListener('click', () => {
        menu.navMenu.classList.remove('show-menu')
    }))
}
showMenu();
closeMenu();
navLinkCloseMenu();