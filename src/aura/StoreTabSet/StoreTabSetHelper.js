({
    lazyLoadTabs: function (cmp, event, tab) {
        switch (tab) {
            case 'store' :
                this.injectComponent('c:MerchandiseStore', cmp.find('storePanel'));
                break;
            case 'history' :
                this.injectComponent('c:OrderHistory', cmp.find('historyPanel'));
                break;
            case 'points' :
                this.injectComponent('c:PointDetail', cmp.find('pointsPanel'));
                break;
        }
    },
    injectComponent: function (name, target) {
        $A.createComponent(name, {
        }, function (contentComponent, status, error) {
            if (status === "SUCCESS") {
                target.set('v.body', contentComponent);
            } else {
                throw new Error(error);
            }
        });
    }
})