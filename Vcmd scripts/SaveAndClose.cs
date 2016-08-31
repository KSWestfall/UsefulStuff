Imports EnvDTE
Imports EnvDTE80
Imports Microsoft.VisualBasic

Public Class C
	Implements VisualCommanderExt.ICommand

	Sub Run(DTE As EnvDTE80.DTE2, package As Microsoft.VisualStudio.Shell.Package) Implements VisualCommanderExt.ICommand.Run
		DTE.ExecuteCommand("File.SaveSelectedItems")
		DTE.ExecuteCommand("File.Close")
	End Sub

End Class
