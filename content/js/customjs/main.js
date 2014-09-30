//===================================================================================================
//Delay Call
function delayCall(func, tst, args)
{
    if (delayCall.tst == tst){
		if(args){
	        func(args);
		} else {
			func();
		}
    }
}
delayCall.tst = 0;

//sum column values
$.fn.sum = function() {
    var res = 0;
    this.each(function(i, v){
		res += parseFloat(v.innerHTML.replace(' ','').replace(',', '.'));
	});
    return res;
}

function currencyFormatter(x){
	res = (Math.round(x * 100) / 100.0 + '').replace('.', ',');
	if (res.length - res.indexOf(',') == 2 && res.indexOf(',') > 0) {
		res += '0';
	}
	else if(res.indexOf(',') == -1) res += ',00';
	return res;
}

function validateDate(input, error)
{	
	var inputVal = input.value.replace(".","/").replace(".","/");
	var result = isDateValid(inputVal);
	return result;
}

function isDateValid(inputDate)
{	
	var validformat=/^\d{2}\/\d{2}\/\d{4}$/;
	if (!validformat.test(inputDate) || !inputDate) return false;
	
	var splitArray = inputDate.split("/");
	var dayfield = splitArray[0];
	var monthfield = splitArray[1];
	var yearfield = splitArray[2];
	var dayobj = new Date(yearfield, monthfield-1, dayfield);
	return ((dayobj.getMonth()+1 == monthfield) && (dayobj.getDate() == dayfield) && (dayobj.getFullYear() == yearfield) && (yearfield > 1900)  && (yearfield < 3000));
}

function round(x, pos){
	return Math.round(Math.pow(10, pos) * x) / Math.pow(10, pos);
}