package au.gov.ga.geodesy.support.commandline;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

import org.junit.Assert;
import org.junit.Test;

public class GeodesyMLCommandLineTest {
	
	@Test
	public void testgetFileName01() {
		String path = "a/b/c/file.txt";
		Assert.assertEquals("file.txt", GeodesyMLCommandLine.getFileName(path));
	}
	@Test
	public void testgetFileName02() {
		String path = "file.txt";
		Assert.assertEquals("file.txt", GeodesyMLCommandLine.getFileName(path));
	}
	
	private static final String outputDir = "/tmp/geodesymltest/commandlinetest";
	static {
		Path outputpath = Paths.get(outputDir);
		try {
			Files.createDirectories(outputpath);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	//@Test
	public void testreturnTestFileStringVer01() throws IOException {
		String pathString = "a/b/c/file.txt";
		String expected = outputDir + "/file.txt";
		String testedPathString = GeodesyMLCommandLine.returnTestFile(outputDir, pathString).toString().replaceAll("\\+", File.separator);
		System.out.println("testedPathString="+testedPathString+"; expected="+expected);
		Assert.assertEquals(expected, testedPathString);
		
	}
	//@Test
	public void testreturnTestFilePathVer01() throws IOException {
		String pathString = "a/b/c/file.txt";
		String expected = outputDir + "/file.txt";
		Path pathStringPath = Paths.get(pathString);
 		Assert.assertEquals(expected, GeodesyMLCommandLine.returnTestFile(outputDir, pathStringPath).toString().replaceAll("\\+", File.separator));
	}
	//@Test
	public void testreturnTestFileStringVer02() throws IOException {
		String pathString = "file.txt";
		String expected = outputDir + "/file.txt";
		Assert.assertEquals(expected, GeodesyMLCommandLine.returnTestFile(outputDir, pathString).toString().replaceAll("\\+", File.separator));
		
	}
	//@Test
	public void testreturnTestFilePathVer02() throws IOException {
		String pathString = "file.txt";
		String expected = outputDir + "/file.txt";
		Path pathStringPath = Paths.get(pathString);
		Assert.assertEquals(expected, GeodesyMLCommandLine.returnTestFile(outputDir, pathStringPath).toString().replaceAll("\\+", File.separator));
	}

}
