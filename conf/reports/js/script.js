$(function() {
    $(".eventId:contains('>>')").replaceWith("<td class='right'><i class='icon-chevron-right'></i></td>");
	$(".eventId:contains('<<')").replaceWith("<td class='left'><i class='icon-chevron-left'></i></td>");
	$(".eventId:contains('!!')").replaceWith("<td class='exclamation'><i class='icon-exclamation-sign'></i></td>");
		
	$("#toggle-in").bind('click', function(){
		$(this).parent().toggleClass("active");
		$("tr td:nth-child(2):not('.right')").parent('tr').toggle();
	});
	$("#toggle-out").bind('click', function(){
		$(this).parent().toggleClass("active");
		$("tr td:nth-child(2):not('.left')").parent('tr').toggle();
	});
	
	$("#toggle-exclamation").bind('click', function(){
		$(this).parent().toggleClass("active");
		$("tr td:nth-child(2):not('.exclamation')").parent('tr').toggle();
	});
	
	$("#toggle-unknown").bind('click', function(){
		$(this).parent().toggleClass("active");
		$(".result").not(":contains('unknown')").parent('tr').toggle();
	});
	
	$("#toggle-fail").bind('click', function(){
		$(this).parent().toggleClass("active");
		$(".result").not(":contains('fail')").parent('tr').toggle();
	});
	
	$("#toggle-success").bind('click', function(){
		$(this).parent().toggleClass("active");
		$(".result").not(":contains('success')").parent('tr').toggle();
	});
	
	$("#toggle-error").bind('click', function(){
		$(this).parent().toggleClass("active");
		$(".result").not(":contains('error')").parent('tr').toggle();
	});
	
	$("#toggle-issue").bind('click', function(){
		$(this).parent().toggleClass("active");
		$(".result").not(":contains('bug')").parent('tr').toggle();
	});
	
});