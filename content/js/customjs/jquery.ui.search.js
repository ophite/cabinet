(function( $ ) {
	var arraySearchQueries = new Array();
	var maxArrayElements = 10;
	
	$.widget( "ui.search", {
		options: {
			search_help_text: '',
			btnSearchText: 'Find',
			searchhandler: null,
		},
		_create: function() {
			var self = this,
				select = this.element.hide();
			var input = this.input = $( "<input>", {
				'class':'ui-autocomplete-input ui-widget ui-widget-content ui-corner-left ui-corner-right',
				})
				.click(function(){
					self._searchfocus(true);
				})
				.blur(function(){
					self._searchfocus(self.getvalue() && self.getvalue().length > 0);
				})
				.keydown(function(event){
					if(event.keyCode==13){
						self.callsearchhandler();
					}
				})
				.insertAfter( select );	
				
			this.span = $('<span>', {
					'id':'searchHelper',
					'class': 'header-mainInfo-helper',
					'text': self.options.search_help_text,
				})
				.click(function(){
					self._searchfocus(true);
				})
				.insertAfter(input);
			
			this.btnBack = $('<button>', {
					'id': 'searchBack',
					'text': 'Назад',
					'class' : 'readonlyBtn',
				})
				.button()
				.click(function(){
					self._backQuery();
				})
				.insertBefore(input);
				
			this.btnSearch = $('<button>', {
					'id':'searchApply',
					'class': 'header-mainInfo-searchApply',
					'text':self.options.btnSearchText,
				})
				.button()
				.click(function(){
					self.callsearchhandler();
				})
				.insertAfter(this.span);
			
			this.btnClear = $('<button>', {
					'id':'searchClear',
					'class': 'header-mainInfo-searchClear',
					'text': 'Очистить',
				})
				.button()
				.click(function(){
					$(input).val('');
					self.callsearchhandler();
				})
				.insertAfter(this.btnSearch);
				
				self._searchfocus(self.getvalue() && self.getvalue().length > 0);
		},
		
		destroy: function() {
			this.input.remove();
			this.span.remove();
			this.btnBack.remove();
			this.btnSearch.remove();
			this.btnClear.remove();
			this.element.show();
			$.Widget.prototype.destroy.call( this );
		},
		
		setvalue: function(newvalue){
			this._searchfocus(true);
			$(this.input).val(newvalue);
		},
		
		getvalue: function(){
			return $(this.input).val() && $(this.input).val().length>0 ? $(this.input).val() : '';
		},
		
		callsearchhandler: function(){
			this._saveQuery();
			if (this.options.searchhandler != null) {
				this.options.searchhandler();
			}
			else {
				this._searchfocus(true);
				this._trigger('searchtrigger', null, {});
			}
		},
		
		_searchfocus: function (focus) {
			if (focus) {
				$(this.input).focus();
			}
			
			this.span.toggle($(this.input).val().length == 0 && !focus);
		},
		
		_saveQuery: function() {
			if (arraySearchQueries.length >= maxArrayElements) {
				arraySearchQueries.shift();
			}
			if($(this.input).val().length > 0) {
				arraySearchQueries.push($(this.input).val());
				if(arraySearchQueries.length == 2) {
					$(this.btnBack).removeClass('readonlyBtn');
				}
			}
		},
		
		_backQuery: function() {
			if (arraySearchQueries.length <= 1) {
				return;
			}
			arraySearchQueries.pop();
			this.setvalue(arraySearchQueries.pop());
			if (arraySearchQueries.length < 1) {
				$(this.btnBack).addClass('readonlyBtn');
			}
			this.callsearchhandler();
		}
	});
}( jQuery ));		
