.box-shadow {
  -moz-box-shadow: 0 0 30px 5px #777777;
  -webkit-box-shadow: 0 0 30px 5px #777777;
}
span.sjRequired {
  color: #931638;
}
* input.sjError {
  background-color: #f2dede;
}
html {
  overflow-y: scroll;
}
body {
  background: #e6e7e8;
  margin: auto;
}
.container-fluid {
  background: white;
  border: 1px solid #c5c9d7;
  padding: 0;
  -moz-box-shadow: 0 0 30px 5px #777777;
  -webkit-box-shadow: 0 0 30px 5px #777777;
}
#header img {
  margin-left: 20px;
}
#footer {
  margin: 20px auto;
  text-align: center;
  width: 90%;
}
.top-bar {
  background: #931638;
  color: #fff;
  padding: 10px;
}
.sj1 a {
  color: #fff;
}
.accordion {
  margin: 0;
}
.accordion-group {
  border: none;
}
.accordion-body {
  /*background: #F7EDF0;*/
  background: #f6f6f6;
}
.accordion-body .table {
  background: #fff;
}
.table thead {
  background: #888fac;
  color: #fff;
}
form {
  margin: 0;
}
#ccSuccess {
  margin: 14px 0 0 0;
}
#photos {
  width: 475px;
}
.adisabled {
  background: #222222;
  opacity: 0.65;
}
div.no_margin_left {
  margin-left: 0px!important;
}
legend {
  font-size: 15px;
  font-weight: bold;
}
.control-group {
  margin-bottom: 5px;
}
.row-fluid .controls-row [class*="span"] + [class*="span"] {
  margin-left: 0px!important;
}
.button-long {
  width: 180px!important;
}
.pac-item {
  margin: 5px auto;
  font-size: 20px;
  height: 30px;
  border-bottom: solid 1px black;
}
legend {
  margin-bottom: 0px;
}
.modal-dialog {
  z-index: 1050;
}
/* styles for validation helpers */
.field-validation-error {
  color: #b94a48;
}
.field-validation-valid {
  display: none;
}
input.input-validation-error {
  border: 1px solid #b94a48;
}
select.input-validation-error {
  border: 1px solid #b94a48;
}
input[type="checkbox"].input-validation-error {
  border: 0 none;
}
.validation-summary-errors {
  color: #b94a48;
}
.validation-summary-valid {
  display: none;
}
/***********************************************/
/* type ahead */
/***********************************************/
.twitter-typeahead {
  width: 100%;
}
.twitter-typeahead .tt-query,
.twitter-typeahead .tt-hint {
  margin-bottom: 0;
}
.tt-dropdown-menu {
  min-width: 160px;
  margin-top: 2px;
  padding: 5px 0;
  background-color: #fff;
  border: 1px solid #ccc;
  border: 1px solid rgba(0, 0, 0, 0.2);
  *border-right-width: 2px;
  *border-bottom-width: 2px;
  -webkit-border-radius: 6px;
  -moz-border-radius: 6px;
  border-radius: 6px;
  -webkit-box-shadow: 0 5px 10px rgba(0, 0, 0, 0.2);
  -moz-box-shadow: 0 5px 10px rgba(0, 0, 0, 0.2);
  box-shadow: 0 5px 10px rgba(0, 0, 0, 0.2);
  -webkit-background-clip: padding-box;
  -moz-background-clip: padding;
  background-clip: padding-box;
  width: 100%;
}
.tt-suggestion {
  display: block;
  padding: 3px 20px;
}
.tt-suggestion.tt-is-under-cursor {
  color: #fff;
  background-color: #0081c2;
  background-image: -moz-linear-gradient(top, #0088cc, #0077b3);
  background-image: -webkit-gradient(linear, 0 0, 0 100%, from(#0088cc), to(#0077b3));
  background-image: -webkit-linear-gradient(top, #0088cc, #0077b3);
  background-image: -o-linear-gradient(top, #0088cc, #0077b3);
  background-image: linear-gradient(to bottom, #0088cc, #0077b3);
  background-repeat: repeat-x;
  filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#ff0088cc', endColorstr='#ff0077b3', GradientType=0);
}
.tt-suggestion.tt-is-under-cursor a {
  color: #fff;
}
.tt-suggestion:hover {
  color: #fff;
  background-color: #0081c2;
  background-image: -moz-linear-gradient(top, #0088cc, #0077b3);
  background-image: -webkit-gradient(linear, 0 0, 0 100%, from(#0088cc), to(#0077b3));
  background-image: -webkit-linear-gradient(top, #0088cc, #0077b3);
  background-image: -o-linear-gradient(top, #0088cc, #0077b3);
  background-image: linear-gradient(to bottom, #0088cc, #0077b3);
  background-repeat: repeat-x;
  filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#ff0088cc', endColorstr='#ff0077b3', GradientType=0);
}
.tt-suggestion p {
  margin: 0;
}

/*# sourceMappingURL=stjude.css.map */
.landingHeader {
	background-attachment: scroll;
	color: white;
	font-weight: bold;
    background-image: url("{!URLFOR($Resource.i360Back)}");
    background-repeat:no-repeat;
    background-position: center center;
    /* background-attachment: fixed; removed for Android */
    -webkit-background-size: cover;
    -moz-background-size: cover;
    -o-background-size: cover;
    background-size: cover;
}

hr {
	border-top: solid 1px #931638;
}