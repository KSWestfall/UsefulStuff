using EnvDTE;
using EnvDTE80;

public class C : VisualCommanderExt.ICommand
{
	public void Run(EnvDTE80.DTE2 DTE, Microsoft.VisualStudio.Shell.Package package) 
	{
		DTE.ExecuteCommand("View.SolutionExplorer");
	}
}
