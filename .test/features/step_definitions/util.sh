@BeforeAll
  . ../bin/tp



@Given {file_role} file `{file_name}`
  ls ${file_name}



@When I run `tp {command} {arg}`
  tp ${command} "${arg}"



@Then `tp` should generate {file_role} file `{file_path}`
  ls "${file_path}"
