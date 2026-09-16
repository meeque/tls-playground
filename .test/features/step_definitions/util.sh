@BeforeAll
  . ../bin/tp



@Given {file_role} file `{file_name}`
  run ls ${file_name}



@When I run `tp {command} {arg}`
  run tp ${command} "${arg}"



@Then `tp` should generate {file_role} file `{file_path}`
  run ls "${file_path}"
