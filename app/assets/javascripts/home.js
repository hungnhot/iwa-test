var Home = {
  init: function(){
    this.homePage = $("#home-page");

    if(this.homePage.length == 0){
      return;
    }

    this.initEvents();
  },


  initEvents: function(){
    var self = this;

    self.initMasonry();
  },

  initMasonry: function(items){
    var self = this;

    if(typeof items == "undefined"){
      items = self.homePage.find(".view-group");
    }

    setTimeout(function () {
      items.find("img").waitForImages(function() {
        items.masonry({
          itemSelector: '.item'
        });
      });
    }, 1000)
  }
}


$(function() {
  Home.init();
});
