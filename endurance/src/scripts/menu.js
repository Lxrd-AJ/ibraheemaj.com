const menu = document.querySelector('.hamburger');

if (menu) {
    menu.addEventListener('click', () => {
        document.querySelector('.nav-links').classList.toggle('expanded');
    });
}
