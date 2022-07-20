const menu = {
    body: document.body,
    navMenu: document.getElementById('nav-menu'),
    menuToggle: document.getElementById('menu-toggle'),
    menuClose: document.getElementById('menu-close'),
    navLink: document.querySelectorAll('#nav-link')
}

const menuActions = () => {
    if (menu.menuToggle) {
        menu.menuToggle.addEventListener('click', () => {
            menu.navMenu.classList.add('show-menu')
        })
    }

    if (menu.menuClose) {
        menu.menuClose.addEventListener('click', () => {
            menu.navMenu.classList.remove('show-menu')
        })
    }

    if (menu.navLink) {
        menu.navLink.forEach(n => n.addEventListener('click', () => {
            menu.navMenu.classList.remove('show-menu')
        }))
    }

    if (menu.body) {
        menu.body.addEventListener('click', (e) => {
            if (!e.target.closest('#nav-menu')) {
                if (!e.target.closest('#menu-toggle')) {
                    menu.navMenu.classList.remove('show-menu')
                }
            }
        })
    }
}

menuActions();
