package br.edu.ifsp.carona.viagens;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.security.servlet.UserDetailsServiceAutoConfiguration;

@SpringBootApplication(exclude = {UserDetailsServiceAutoConfiguration.class})
public class MsViagensApplication {

    public static void main(String[] args) {
        SpringApplication.run(MsViagensApplication.class, args);
    }
}