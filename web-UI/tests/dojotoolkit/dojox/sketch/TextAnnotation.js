dojo.provide("dojox.sketch.TextAnnotation");
dojo.require("dojox.sketch.Annotation");
dojo.require("dojox.sketch.Anchor");

(function(){
	var ta=dojox.sketch;
	ta.TextAnnotation=function(figure, id){
		ta.Annotation.call(this, figure, id);
		this.transform={dx:0, dy:0};
		this.start={x:0, y:0};
		this.property('label','');
		this.labelShape=null;
		this.lineShape=null;
		//this.anchors.start=new ta.Anchor(this, "start");
	};
	ta.TextAnnotation.prototype=new ta.Annotation;
	var p=ta.TextAnnotation.prototype;
	p.constructor=ta.TextAnnotation;

	p.type=function(){ return 'Text'; };
	p.getType=function(){ return ta.TextAnnotation; };

	p.apply=function(obj){
		if(!obj){ return; }
		if(obj.documentElement){ obj=obj.documentElement; }
		this.readCommonAttrs(obj);
		
		for(var i=0; i<obj.childNodes.length; i++){
			var c=obj.childNodes[i];
			if(c.localName=="text"){
				this.property('label',c.childNodes[0].nodeValue);
				var style=c.getAttribute('style');
				var m=style.match(/fill:([^;]+);/);
				if(m){
					var stroke=this.property('stroke');
					stroke.collor=m[1];
					this.property('stroke',stroke);
					this.property('fill',stroke.collor);
				}
			}/*else if(c.localName=="line"){
				var stroke=this.property('stroke');
				var style=c.getAttribute('style');
				var m=style.match(/stroke:([^;]+);/)[1];
				if(m){
					stroke.color=m;
					this.property('fill',m);
				}
				m=style.match(/stroke-width:([^;]+);/)[1];
				if(m){
					stroke.width=m;
				}
				this.property('stroke',stroke);
			}*/
		}
	};
	
	p.initialize=function(obj){
		//var font=(ta.Annotation.labelFont)?ta.Annotation.labelFont:{family:"Times", size:"16px"};
		this.apply(obj);
 
		//	create either from scratch or based on the passed node
		this.shape=this.figure.group.createGroup();
		this.shape.getEventSource().setAttribute("id", this.id);
		//if(this.transform.dx || this.transform.dy){ this.shape.setTransform(this.transform); }


	  // pop up dialog box automatically to get initial text
	  var l=prompt('Write text:',this.property('label'));
	  if(l==false){l='text';}  // put in default if nothing entered
	  this.property('label',l);

	  this.labelShape=this.shape.createText({
				x:0, 
				y:0, 
				text:this.property('label'), 
				align:"start"
			})
			//.setFont(font)
			//.setFill(this.property('fill'));
		this.labelShape.getEventSource().setAttribute('id',this.id+"-labelShape");

		this.lineShape=this.shape.createLine({ 
				x1:1, 
				x2:this.labelShape.getTextWidth(), 
				y1:2, 
				y2:2 
			})
			//.setStroke({ color:this.property('fill'), width:1 });
		this.lineShape.getEventSource().setAttribute("shape-rendering","crispEdges");
	  
	  this.draw();
	  
	};
	p.destroy=function(){
		if(!this.shape){ return; }
		this.shape.remove(this.labelShape);
		this.shape.remove(this.lineShape);
		this.figure.group.remove(this.shape);
		this.shape=this.lineShape=this.labelShape=null;
	};
	p.getBBox=function(){
		var b=this.getTextBox();
		return { x:0, y:(b.h*-1+4)/this.figure.zoomFactor, width:(b.w+2)/this.figure.zoomFactor, height:b.h/this.figure.zoomFactor };
	};
	p.draw=function(obj){
		this.apply(obj);
		this.shape.setTransform(this.transform);
		this.labelShape.setShape({ x:0, y:0, text:this.property('label') })
			.setFill(this.property('fill'));
		this.zoom();
	};
	p.zoom=function(pct){
		if(this.lineShape){
			pct = pct || this.figure.zoomFactor;
			ta.Annotation.prototype.zoom.call(this,pct);
			this.lineShape.setShape({ x1:1, x2:this.labelShape.getTextWidth()+1, y1:2, y2:2 })
				.setStroke({ color:this.property('fill'), width:1/pct });
			if(this.mode==ta.Annotation.Modes.Edit){
				this.drawBBox(); //the bbox is dependent on the size of the text, so need to update it here
			}
		}
	};
	p.serialize=function(){
		var s=this.property('stroke');
		return '<g '+this.writeCommonAttrs()+'>'
			//+ '<line x1="1" x2="'+this.labelShape.getTextWidth()+1+'" y1="5" y2="5" style="stroke:'+s.color+';stroke-width:'+s.width+';" />'
			+ '<text style="fill:'+this.property('fill')+';" font-weight="medium" '
			+ 'x="0" y="0">'
			+ this.property('label')
			+ '</text>'
			+ '</g>';
	};

	ta.Annotation.register("Text");
})();
