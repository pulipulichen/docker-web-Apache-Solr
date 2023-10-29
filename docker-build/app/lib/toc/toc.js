var toc = document.querySelector( '.toc' );
var tocPath = document.querySelector( '.toc-marker path' );
var tocItems;

// Factor of screen size that the element must cross
// before it's considered visible
var TOP_MARGIN = 0.1,
    BOTTOM_MARGIN = 0.2;

var pathLength;

$(document).ready(function() {

  listHeadings()

  window.addEventListener( 'resize', drawPath, false );
  window.addEventListener( 'scroll', sync, false );
  $('.toc a').click(sync)

  drawPath();

})

function listHeadings() {
  // let lastLevel = 1
  let headingsArray = []
  let currentHeading = null
  let headingIDcount = 0

  $('.contents h1, .contents h2').each(function () {
    var level = this.tagName.toLowerCase();
    var text = $(this).text();

    let id = this.id
    // console.log({id})
    if (!id || id == '') {
      id = 'header_' + headingIDcount
      $(this).prop('id', id)
      headingIDcount++
    }

    if (level === 'h1') {
        currentHeading = { level: level, text: text, subheadings: [], id };
        headingsArray.push(currentHeading);
    } else {
      if (currentHeading) {
          currentHeading.subheadings.push({ level: level, text: text, id });
      }
    }
  })
  
  // console.log(headingsArray)
  var tocUL = $( '.toc:first > ul.main' );
  headingsArray.forEach(({text, id, subheadings}) => {
    let li = $(`<li><a href="#${id}">${text}</a></li>`)
    li.appendTo(tocUL)

    if (subheadings.length > 0) {
      let ulSub = $(`<ul></ul>`).appendTo(li)

      subheadings.forEach(({text, id}) => {
        let liSub = $(`<li><a href="#${id}">${text}</a></li>`)
        liSub.appendTo(ulSub)
      })
    }
  })
}

function drawPath() {

  tocItems = [].slice.call( toc.querySelectorAll( 'li' ) );

  // Cache element references and measurements
  tocItems = tocItems.map( function( item ) {
    var anchor = item.querySelector( 'a' );
    var target = document.getElementById( anchor.getAttribute( 'href' ).slice( 1 ) );

    return {
      listItem: item,
      anchor: anchor,
      target: target
    };
  } );

  // Remove missing targets
  tocItems = tocItems.filter( function( item ) {
    return !!item.target;
  } );

  var path = [];
  var pathIndent;

  tocItems.forEach( function( item, i ) {

    var x = item.anchor.offsetLeft - 5,
        y = item.anchor.offsetTop,
        height = item.anchor.offsetHeight;

    if( i === 0 ) {
      path.push( 'M', x, y, 'L', x, y + height );
      item.pathStart = tocPath.getTotalLength() || 0;
    }
    else {
      // Draw an additional line when there's a change in
      // indent levels
      if( pathIndent !== x ) path.push( 'L', pathIndent, y );

      path.push( 'L', x, y );

      // Set the current path so that we can measure it
      tocPath.setAttribute( 'd', path.join( ' ' ) );
      item.pathStart = tocPath.getTotalLength() || 0;

      path.push( 'L', x, y + height );
    }

    pathIndent = x;

    tocPath.setAttribute( 'd', path.join( ' ' ) );
    item.pathEnd = tocPath.getTotalLength();

  } );

  pathLength = tocPath.getTotalLength();

  sync();

}

function sync() {

  var windowHeight = window.innerHeight;

  var pathStart = Number.MAX_VALUE,
      pathEnd = 0;

  var visibleItems = 0;

  tocItems.forEach( function( item ) {

    var targetBounds = item.target.getBoundingClientRect();

    if( targetBounds.bottom > windowHeight * TOP_MARGIN && targetBounds.top < windowHeight * ( 1 - BOTTOM_MARGIN ) ) {
      pathStart = Math.min( item.pathStart, pathStart );
      pathEnd = Math.max( item.pathEnd, pathEnd );

      visibleItems += 1;

      item.listItem.classList.add( 'visible' );
    }
    else {
      item.listItem.classList.remove( 'visible' );
    }

  } );

  // Specify the visible path or hide the path altogether
  // if there are no visible items
  if( visibleItems > 0 && pathStart < pathEnd ) {
    tocPath.setAttribute( 'stroke-dashoffset', '1' );
    tocPath.setAttribute( 'stroke-dasharray', '1, '+ pathStart +', '+ ( pathEnd - pathStart ) +', ' + pathLength );
    tocPath.setAttribute( 'opacity', 1 );
  }
  else {
    tocPath.setAttribute( 'opacity', 0 );
  }

}