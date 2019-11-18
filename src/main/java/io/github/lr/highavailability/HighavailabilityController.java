package io.github.lr.highavailability;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HighavailabilityController {

	private DateTimeFormatter datetimeFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss");
	
	@GetMapping(value = "/")
	public ResponseEntity<String> time() {
		return new ResponseEntity<String>(datetimeFormatter.format(LocalDateTime.now()), HttpStatus.OK);
	}
	
}
