require('UIColor');
defineClass('JPViewController', {
            handleBtn: function(sender) {
            var tableViewCtrl = JPTableViewController.alloc().init()
            self.navigationController().pushViewController_animated(tableViewCtrl, YES)
            }
            })

defineClass('JPTableViewController : UITableViewController <UIAlertViewDelegate>', ['data'], {
            dataSource: function() {
            var data = self.data();
            if (data) return data;
            var data = [];
            for (var i = 0; i < 20; i ++) {
            data.push("cell from js " + i);
            }
            self.setData(data)
            return data;
            },
			viewDidLoad: function() {
			        self.super().viewDidLoad();
			        self.view().setBackgroundColor(UIColor.redColor());
                    self.setTitle("DJComponentHotfix Test");
			    },
            })