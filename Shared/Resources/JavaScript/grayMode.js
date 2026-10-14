function grayMode() {
    var filter = '-webkit-filter:grayscale(100%);-moz-filter:grayscale(100%); -ms-filter:grayscale(100%); -o-filter:grayscale(100%) filter:grayscale(100%);';
    document.getElementsByTagName('html')[0].style.filter = 'grayscale(100%)';
}
