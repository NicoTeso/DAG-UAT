({
    unrender: function (cmp, helper) {
        this.superUnrender();
        window.clearInterval(cmp.get("v.win"));
    }
})