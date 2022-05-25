/*
 Highcharts JS v6.1.1 (2018-06-27)
 Module for adding patterns and images as point fills.

 (c) 2010-2018 Highsoft AS
 Author: Torstein Hnsi, ystein Moseng

 License: www.highcharts.com/license
*/
(function(h){"object"===typeof module&&module.exports?module.exports=h:h(Highcharts)})(function(h){(function(e){function h(a,b){a=JSON.stringify(a);var d=a.length||0,c=0,e=0;if(b){b=Math.max(Math.floor(d/500),1);for(var g=0;g<d;g+=b)c+=a.charCodeAt(g);c&=c}for(;e<d;++e)b=a.charCodeAt(e),c=(c<<5)-c+b,c&=c;return c.toString(16).replace("-","1")}var m=e.wrap,k=e.each,n=e.merge,p=e.pick;e.Point.prototype.calculatePatternDimensions=function(a){if(!a.width||!a.height){var b=this.graphic&&(this.graphic.getBBox&&
this.graphic.getBBox(!0)||this.graphic.element&&this.graphic.element.getBBox())||{},d=this.shapeArgs;d&&(b.width=d.width||b.width,b.height=d.height||b.height,b.x=d.x||b.x,b.y=d.y||b.y);if(a.image){if(!b.width||!b.height){a._width="defer";a._height="defer";return}a.aspectRatio&&(b.aspectRatio=b.width/b.height,a.aspectRatio>b.aspectRatio?b.aspectWidth=b.height*a.aspectRatio:b.aspectHeight=b.width/a.aspectRatio);a._width=a.width||Math.ceil(b.aspectWidth||b.width);a._height=a.height||Math.ceil(b.aspectHeight||
b.height)}a.width||(a._x=a.x||0,a._x+=b.x-Math.round(b.aspectWidth?Math.abs(b.aspectWidth-b.width)/2:0));a.height||(a._y=a.y||0,a._y+=b.y-Math.round(b.aspectHeight?Math.abs(b.aspectHeight-b.height)/2:0))}};e.SVGRenderer.prototype.addPattern=function(a,b){var d;b=e.pick(b,!0);var c=e.animObject(b),f,g=a.width||a._width||32,h=a.height||a._height||32,m=a.color||"#343434",l=a.id,n=this,q=function(a){n.rect(0,0,g,h).attr({fill:a}).add(d)};l||(this.idCounter=this.idCounter||0,l="highcharts-pattern-"+this.idCounter,
++this.idCounter);this.defIds=this.defIds||[];if(!(-1<e.inArray(l,this.defIds)))return this.defIds.push(l),d=this.createElement("pattern").attr({id:l,patternUnits:"userSpaceOnUse",width:g,height:h,x:a._x||a.x||0,y:a._y||a.y||0}).add(this.defs),d.id=l,a.path?(f=a.path,f.fill&&q(f.fill),this.createElement("path").attr({d:f.d||f,stroke:f.stroke||m,"stroke-width":f.strokeWidth||2}).add(d),d.color=m):a.image&&(b?this.image(a.image,0,0,g,h,function(){this.animate({opacity:p(a.opacity,1)},c);e.removeEvent(this.element,
"load")}).attr({opacity:0}).add(d):this.image(a.image,0,0,g,h).add(d)),a.image&&b||void 0===a.opacity||k(d.element.childNodes,function(b){b.setAttribute("opacity",a.opacity)}),this.patternElements=this.patternElements||{},this.patternElements[l]=d};m(e.Series.prototype,"getColor",function(a){var b=this.options.color;b&&b.pattern&&!b.pattern.color?(delete this.options.color,a.apply(this,Array.prototype.slice.call(arguments,1)),b.pattern.color=this.color,this.color=this.options.color=b):a.apply(this,
Array.prototype.slice.call(arguments,1))});m(e.Series.prototype,"render",function(a){var b=this.chart.isResizing;(this.isDirtyData||b||!this.chart.hasRendered)&&k(this.points||[],function(a){var c=a.options&&a.options.color;c&&c.pattern&&(!b||a.shapeArgs&&a.shapeArgs.width&&a.shapeArgs.height?a.calculatePatternDimensions(c.pattern):(c.pattern._width="defer",c.pattern._height="defer"))});return a.apply(this,Array.prototype.slice.call(arguments,1))});m(e.Point.prototype,"applyOptions",function(a){var b=
a.apply(this,Array.prototype.slice.call(arguments,1)),d=b.options.color;d&&d.pattern&&("string"===typeof d.pattern.path&&(d.pattern.path={d:d.pattern.path}),b.color=b.options.color=n(b.series.options.color,d));return b});e.addEvent(e.SVGRenderer,"complexColor",function(a){var b=a.args[0],d=a.args[1];a=a.args[2];var c=b.pattern,f="#343434",g;if(!c)return!0;if(c.image||"string"===typeof c.path||c.path&&c.path.d){g=(g=a.parentNode&&a.parentNode.getAttribute("class"))&&-1<g.indexOf("highcharts-legend");
"defer"!==c._width&&"defer"!==c._height||e.Point.prototype.calculatePatternDimensions.call({graphic:{element:a}},c);if(g||!c.id)c=n({},c),c.id="highcharts-pattern-"+h(c)+h(c,!0);this.addPattern(c,!this.forExport&&e.pick(c.animation,this.globalAnimation,{duration:100}));f="url("+this.url+"#"+c.id+")"}else f=c.color||f;a.setAttribute(d,f);b.toString=function(){return f};return!1});e.addEvent(e.Chart,"endResize",function(){e.grep(this.renderer.defIds||[],function(a){return a&&a.indexOf&&0===a.indexOf("highcharts-pattern-")}).length&&
(k(this.series,function(a){k(a.points,function(a){(a=a.options&&a.options.color)&&a.pattern&&(a.pattern._width="defer",a.pattern._height="defer")})}),this.redraw(!1))});e.addEvent(e.Chart,"redraw",function(){var a=[],b=this.renderer,d=e.grep(b.defIds||[],function(a){return a.indexOf&&0===a.indexOf("highcharts-pattern-")});d.length&&(k(this.renderTo.querySelectorAll('[color^\x3d"url(#"], [fill^\x3d"url(#"], [stroke^\x3d"url(#"]'),function(b){(b=b.getAttribute("fill")||b.getAttribute("color")||b.getAttribute("stroke"))&&
a.push(b.substring(b.indexOf("url(#")+5).replace(")",""))}),k(d,function(c){-1===e.inArray(c,a)&&(e.erase(b.defIds,c),b.patternElements[c]&&(b.patternElements[c].destroy(),delete b.patternElements[c]))}))});e.Chart.prototype.callbacks.push(function(a){var b=e.getOptions().colors;k("M 0 0 L 10 10 M 9 -1 L 11 1 M -1 9 L 1 11;M 0 10 L 10 0 M -1 1 L 1 -1 M 9 11 L 11 9;M 3 0 L 3 10 M 8 0 L 8 10;M 0 3 L 10 3 M 0 8 L 10 8;M 0 3 L 5 3 L 5 0 M 5 10 L 5 7 L 10 7;M 3 3 L 8 3 L 8 8 L 3 8 Z;M 5 5 m -4 0 a 4 4 0 1 1 8 0 a 4 4 0 1 1 -8 0;M 10 3 L 5 3 L 5 0 M 5 10 L 5 7 L 0 7;M 2 5 L 5 2 L 8 5 L 5 8 Z;M 0 0 L 5 10 L 10 0".split(";"),
function(d,c){a.renderer.addPattern({id:"highcharts-default-pattern-"+c,path:d,color:b[c],width:10,height:10})})})})(h)});
