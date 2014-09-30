(function( $ ) {
	$.widget( "ui.combobox", {
		options: {
			isLocal: false,
			dirtyhandler:null,
			key:"", 
			initialOID:"", 
			initialtext:""
		},
		_create: function() {
			var self = this,
				select = this.element.hide();
				
				self._fillComboboxCurrentValue(self.options.key, self.options.initialOID, self.options.initialtext);
				selected = select.children( ":selected" );
				value = selected.val() ? selected.text() : "";
			var input = this.input = $( "<input>" )
				.insertAfter( select )
				.val( value )
				.autocomplete({
					delay: 0,
					minLength: 0,
					source: function( request, response ) {
						var matcher = new RegExp( $.ui.autocomplete.escapeRegex(request.term), "i" );
						response( select.children( "option" ).map(function() {
							var text = $( this ).text();
							if ( this.value && ( !request.term || matcher.test(text) ) )
								return {
									label: text.replace(
										new RegExp(
											"(?![^&;]+;)(?!<[^<>]*)(" +
											$.ui.autocomplete.escapeRegex(request.term) +
											")(?![^<>]*>)(?![^&;]+;)", "gi"
										), "<strong>$1</strong>" ),
									value: text,
									option: this
								};
						}) );
					},
					select: function( event, ui ) {
						self._trigger("select", event, ui);
						
						ui.item.option.selected = true;
						self._trigger( "selected", event, {
							item: ui.item.option
						});
						
						if (select.attr('oid') !== $(ui.item.option).attr('oid') && self.options.dirtyhandler != null)
							self.options.dirtyhandler();
							
						select.attr('oid', $(ui.item.option).attr('oid'));
					},
					change: function( event, ui ) {
						if ( !ui.item ) {
							var matcher = new RegExp( "^" + $.ui.autocomplete.escapeRegex( $(this).val() ) + "$", "i" ),
								valid = false;
							select.children( "option" ).each(function() {
								if ( $( this ).text().match( matcher ) ) {
									this.selected = valid = true;
									return false;
								}
							});
							if ( !valid ) {
								// remove invalid value, as it didn't match anything
								$( this ).val( "" );
								select.val( "" );
								input.data( "autocomplete" ).term = "";
								return false;
							}
						}
					}
				})
				.addClass( "ui-widget ui-widget-content ui-corner-left" );

			input.data( "autocomplete" )._renderItem = function( ul, item ) {
				return $( "<li></li>" )
					.data( "item.autocomplete", item )
					.append( "<a>" + item.label + "</a>" )
					.appendTo( ul );
			};

			this.isLoad = false;
			
			this.button = $( "<button>&nbsp;</button>" )
				.attr( "tabIndex", -1 )
				.attr( "title", "Show All Items" )
				.insertAfter( input )
				.button({
					icons: {
						primary: "ui-icon-triangle-1-s"
					},
					text: false
				})
				.removeClass( "ui-corner-all" )
				.addClass( "ui-corner-right ui-button-icon" )
				.click(function() {
					self.autocompleteElement = input;
					
					if (self.options.isLocal && !self.isLoad) {
						self._trigger('loadData', null, {
							self: self,
							callback: self.showAutocomplete
						});
					}
					else {
						self.showAutocomplete(self);
					}
				});
		},
		
		destroy: function() {
			this.input.remove();
			this.button.remove();
			this.element.show();
			$.Widget.prototype.destroy.call( this );
		},
		
		showAutocomplete: function(self){
			self.isLoad = true;
			// close if already visible
			if (self.autocompleteElement.autocomplete("widget").is(":visible")) {
				self.autocompleteElement.autocomplete("close");
				return;
			}
			
			// pass empty string as value to search for, displaying all results
			self.autocompleteElement.autocomplete("search", "");
			self.autocompleteElement.focus();
		},
		
		select : function(event, ui){
		},
		
		ajax : function (data, ajaxUrl, ajaxParams) {
			var control = $("#id_" + data.self.options.key + "ID");
			$.ajax({
				url: ajaxUrl,
				data: ajaxParams,
				dataType: "json",
				mtype: "GET",
				complete: function(jsondata, stat){
					if (stat == "success") {
						data.self._fillCombobox(data.self, jsondata);
						data.callback(data.self);
					}
				},
				error: function(){
					alert("unfriendly ajax error");
				}
			});
		},
		
		_fillCombobox: function (self, jsondata){
			var control = $("#id_" + self.options.key + "ID");
			var items = json_parse(jsondata.responseText);
			var selectedOID;
			
			for (var i = 0; i < items.length; i++) {
				if ($("#id_" + self.options.key + "ID" + " > option[oid='" + items[i].OID + "']").length === 0) {
					$('<option>')
					.text(items[i][self.options.key + "Name"])
					.addClass('ui-widget-content')
					.attr( {
						'oid': items[i].OID,
						'selected': items[i].OID == self.options.initialOID
					})
					.appendTo(control);
					
					if ( items[i].OID == self.options.initialOID){
						selectedOID = items[i].OID; 
					}
				}
			}
			
			if (items.length > 0 && selectedOID) {
				control.attr('oid', selectedOID);
			}
		},
		
		_fillComboboxCurrentValue: function (key, OID, text){
			var control = $("#id_"+key + "ID");
			
			if (control !== 'None') {
				$('<option>')
				.text(text)
				.attr({
					'oid': OID === 'None' ? '' : OID,
					'value': OID === 'None' ? '' : OID,
					'selected': true
				})
				.appendTo(control);
			}
			
			control.attr('oid', OID === 'None' ? '' : OID);
		},

	});
}( jQuery ));