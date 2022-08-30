<!DOCTYPE html>
<html>
<head>
<title>Testing Index file: index.jsp</title>
</head>
<body>
<h1>Testing Include Extension: inc</h1>
<?php include('includes/file.inc'); ?>
<!--#include virtual="/include-test/includes/file.inc"-->
<h1>Testing Include Extension: php</h1>
<?php include('includes/file.php'); ?>
<!--#include virtual="/include-test/includes/file.php"-->
<h1>Testing Include Extension: aspx</h1>
<?php include('includes/file.aspx'); ?>
<!--#include virtual="/include-test/includes/file.aspx"-->
<h1>Testing Include Extension: html</h1>
<?php include('includes/file.html'); ?>
<!--#include virtual="/include-test/includes/file.html"-->
<h1>Testing Include Extension: htm</h1>
<?php include('includes/file.htm'); ?>
<!--#include virtual="/include-test/includes/file.htm"-->
<h1>Testing Include Extension: shtml</h1>
<?php include('includes/file.shtml'); ?>
<!--#include virtual="/include-test/includes/file.shtml"-->
<h1>Testing Include Extension: asp</h1>
<?php include('includes/file.asp'); ?>
<!--#include virtual="/include-test/includes/file.asp"-->
<h1>Testing Include Extension: txt</h1>
<?php include('includes/file.txt'); ?>
<!--#include virtual="/include-test/includes/file.txt"-->
</body>
</html>