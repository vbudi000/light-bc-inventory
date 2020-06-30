package catalog;

import org.springframework.context.ApplicationContextInitializer;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.core.io.Resource;
import org.springframework.core.io.ByteArrayResource;
import java.io.IOException;
import org.springframework.boot.env.YamlPropertySourceLoader;
import org.springframework.core.env.PropertySource;


public class VcapProcessor implements ApplicationContextInitializer<ConfigurableApplicationContext> {
  @Override
  public void initialize(ConfigurableApplicationContext applicationContext) {
    try {
        System.out.println("In VcapProcessor initialize");
        Resource resource = applicationContext.getResource("classpath:application.yml");
        YamlPropertySourceLoader sourceLoader = new YamlPropertySourceLoader();
        PropertySource<?> yamlTestProperties = sourceLoader.load("yamlTestProperties", resource, null);
        applicationContext.getEnvironment().getPropertySources().addFirst(yamlTestProperties);
        String vcapURI = applicationContext.getEnvironment().getProperty("vcap.uri");
        System.out.println("vcap.uri from application.yml: "+vcapURI);
        if (vcapURI.startsWith("mysql")) {
            int ustart = vcapURI.indexOf("://")+3;
            String username = vcapURI.substring(ustart,vcapURI.indexOf(":",ustart));
            String password = vcapURI.substring(vcapURI.indexOf(":",ustart)+1,vcapURI.indexOf("@"));
            String uri = "jdbc:mysql://"+vcapURI.substring(vcapURI.indexOf("@")+1,vcapURI.indexOf("/",ustart))+"/inventorydb";
            String ymlSrc = "spring: \n  datasource:\n    username: "+username+"\n    password: "+password+"\n    url: "+uri;
            System.out.println(ymlSrc);
            ByteArrayResource bar = new ByteArrayResource(ymlSrc.getBytes());
            PropertySource<?> newDataSource = sourceLoader.load("newDataSource",bar,null);
            applicationContext.getEnvironment().getPropertySources().addFirst(newDataSource);
            System.out.println("****: "+applicationContext.getEnvironment().getProperty("spring.datasource.url"));
        } else {
            String uri = applicationContext.getEnvironment().getProperty("spring.datasource.url");
            System.out.println("spring.datasource.url from application.yml: "+uri); 
            String username = applicationContext.getEnvironment().getProperty("spring.datasource.username");
            System.out.println("spring.datasource.username from application.yml: "+username);
            String password = applicationContext.getEnvironment().getProperty("spring.datasource.password");
            System.out.println("spring.datasource.password from application.yml: "+password); 
            String ymlSrc = "spring: \n  datasource:\n    username: "+username+"\n    password: "+password+"\n    url: "+uri;
            System.out.println(ymlSrc);
            ByteArrayResource bar = new ByteArrayResource(ymlSrc.getBytes());
            PropertySource<?> newDataSource = sourceLoader.load("newDataSource",bar,null);
            applicationContext.getEnvironment().getPropertySources().addFirst(newDataSource);
            System.out.println("****: "+applicationContext.getEnvironment().getProperty("spring.datasource.url"));          
        }  
    } catch (IOException e) {
        throw new RuntimeException(e);
    }
  }
}
