channy@channy-VirtualBox:~/Documents/gitCode/postgresql-12.1/src$ git diff backend/commands/functioncmds.c
diff --git a/backend/commands/functioncmds.c b/backend/commands/functioncmds.c
index 40f1f9a..6f35fc8 100644
--- a/backend/commands/functioncmds.c
+++ b/backend/commands/functioncmds.c
@@ -304,10 +304,10 @@ interpret_function_parameter_list(ParseState *pstate,
                /* handle output parameters */
                if (fp->mode != FUNC_PARAM_IN && fp->mode != FUNC_PARAM_VARIADIC)
                {
-                       if (objtype == OBJECT_PROCEDURE)
-                               *requiredResultType = RECORDOID;
-                       else if (outCount == 0) /* save first output param's type */
-                               *requiredResultType = toid;
+                       //if (objtype == OBJECT_PROCEDURE)
+                       //      *requiredResultType = RECORDOID;
+                       //else if (outCount == 0) /* save first output param's type */
+                       //      *requiredResultType = toid;
                        outCount++;
                }
 
@@ -435,8 +435,8 @@ interpret_function_parameter_list(ParseState *pstate,
                                                                                         sizeof(Oid), true, 'i');
                *parameterModes = construct_array(paramModes, parameterCount, CHAROID,
                                                                                  1, true, 'c');
-               if (outCount > 1)
-                       *requiredResultType = RECORDOID;
+               //if (outCount > 1)
+               //      *requiredResultType = RECORDOID;
                /* otherwise we set requiredResultType correctly above */
        }
        else



channy@channy-VirtualBox:~/Documents/gitCode/postgresql-12.1/src$ git diff pl/plpgsql/src/pl_gram.y
diff --git a/pl/plpgsql/src/pl_gram.y b/pl/plpgsql/src/pl_gram.y
index af63fe1..f7de066 100644
--- a/pl/plpgsql/src/pl_gram.y
+++ b/pl/plpgsql/src/pl_gram.y
@@ -3255,6 +3255,8 @@ make_return_stmt(int location)
        }
        else if (plpgsql_curr_compile->out_param_varno >= 0)
        {
+               int tok = yylex();
+
                if (yylex() != ';')
                        ereport(ERROR,
                                        (errcode(ERRCODE_DATATYPE_MISMATCH),
chan