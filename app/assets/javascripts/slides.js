// Päivitetään kelmulistaa automaattisesti 60s välein
var refreshTimer = $.timer(function() {
	$('[data-refresh-url]').each(function(index, element) {
		
		$.ajax({
			type: "GET",
			url: $(this).attr('data-refresh-url'),
			dataType: 'script'
		});
	});
	if ($('[data-refresh-url]').length == 0) refreshTimer.stop();
}, 300000, true);

function scrollToAnchor(aid){
    var aTag = $("a[name='"+ aid +"']");
    $('html,body').animate({scrollTop: aTag.offset().top},200);
};

jQuery(function($) {
	$(".group_link").click(function(e) {
   		e.preventDefault();
		var full_url = this.href;

		//split the url by # and get the anchor target name - home in mysitecom/index.htm#home
		var parts = full_url.split("#");
		var target = parts[1];


		scrollToAnchor(target);
	});
});