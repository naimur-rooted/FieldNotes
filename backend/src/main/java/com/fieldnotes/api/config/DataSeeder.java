package com.fieldnotes.api.config;

import com.fieldnotes.api.entity.Customer;
import com.fieldnotes.api.entity.FieldNote;
import com.fieldnotes.api.entity.Site;
import com.fieldnotes.api.entity.User;
import com.fieldnotes.api.repository.CustomerRepository;
import com.fieldnotes.api.repository.FieldNoteRepository;
import com.fieldnotes.api.repository.SiteRepository;
import com.fieldnotes.api.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.List;

/**
 * Automatically seeds the demo account (demo@test.com / demo123) with realistic
 * customers, job sites, and field inspection notes on startup if not already present.
 */
@Component
public class DataSeeder implements CommandLineRunner {

    private static final Logger log = LoggerFactory.getLogger(DataSeeder.class);

    private final UserRepository userRepository;
    private final CustomerRepository customerRepository;
    private final SiteRepository siteRepository;
    private final FieldNoteRepository fieldNoteRepository;
    private final PasswordEncoder passwordEncoder;

    public DataSeeder(UserRepository userRepository,
                      CustomerRepository customerRepository,
                      SiteRepository siteRepository,
                      FieldNoteRepository fieldNoteRepository,
                      PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.customerRepository = customerRepository;
        this.siteRepository = siteRepository;
        this.fieldNoteRepository = fieldNoteRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    public void run(String... args) {
        try {
            seedDemoData();
        } catch (Exception e) {
            log.warn("Notice: demo data seeding skipped or encountered error: {}", e.getMessage());
        }
    }

    private void seedDemoData() {
        // 1. Ensure demo user exists
        User demoUser = userRepository.findByEmail("demo@test.com").orElseGet(() -> {
            User u = new User();
            u.setName("Alex Vance (Lead Field Engineer)");
            u.setEmail("demo@test.com");
            u.setPassword(passwordEncoder.encode("demo123"));
            log.info("Creating demo user: demo@test.com");
            return userRepository.save(u);
        });

        // 2. Check if user already has notes
        List<FieldNote> existingNotes = fieldNoteRepository.findAllByUserWithRelations(demoUser.getId());
        if (!existingNotes.isEmpty()) {
            log.info("Demo user already has {} field notes. Skipping seed.", existingNotes.size());
            return;
        }

        log.info("Seeding realistic sample data for demo account...");

        // Customers
        Customer c1 = createCustomer("Apex Builders Ltd", "+1-555-0199 / contact@apexbuilders.com", demoUser);
        Customer c2 = createCustomer("Metro Urban Infrastructure", "info@metrourban.org / +1-555-0245", demoUser);
        Customer c3 = createCustomer("Skyline Renewable Energy", "ops@skylinerenewables.com | +1 (555) 882-3419", demoUser);

        // Sites
        Site s1 = createSite("Downtown Plaza - Tower A", "104 Main Street, Sector 4", c1, demoUser);
        Site s2 = createSite("Riverside Bridge Overpass", "Bridge Pier 7, East Highway", c2, demoUser);
        Site s3 = createSite("Solaria Solar Field - Array Beta", "Highway 95 North, Solar Corridor, NV", c3, demoUser);
        Site s4 = createSite("Marina Horizon Condos - Phase 2", "84 Harbor Boulevard, Pier 3, Austin, TX", c1, demoUser);

        // Field Notes with realistic statuses, locations, and timestamps
        Instant now = Instant.now();

        createNote(s1, demoUser,
                "Foundation Level 2 Structural Integrity Check",
                "Completed ultrasonic non-destructive testing on shear wall SW-4 and Column B4. Concrete core compressive strength verified at 5,420 psi (exceeding 5,000 psi spec). Rebar clearance and vapor barrier certified for next deck pouring phase.",
                "Basement B2, Grid 4-D (30.2672 N, 97.7431 W)",
                now.minus(2, ChronoUnit.DAYS),
                "DONE");

        createNote(s2, demoUser,
                "Expansion Joint Sealant Replacement",
                "High-cycle thermal expansion causing micro-fissures in silicone elastomeric sealant along transverse joint J-03. Polyurethane backer rod intact. Clean joint cavity and re-apply Dow Corning 902 RCS self-leveling sealant before rainfall.",
                "East Span Pier 7 (30.2710 N, 97.7390 W)",
                now.minus(18, ChronoUnit.HOURS),
                "OPEN");

        createNote(s3, demoUser,
                "Inverter String 14 DC Ground Fault Cleared",
                "Isolated low insulation resistance trip on central inverter unit #3. Traced chafed 1.5kV PV wire insulation near metal conduit entry. Resleeved with dual-wall heat-shrink tubing. Post-repair megger test: > 850 M-ohm. String successfully restored to grid.",
                "Combiner Box CB-14, Row 9 (36.0395 N, 114.9817 W)",
                now.minus(1, ChronoUnit.DAYS),
                "DONE");

        createNote(s1, demoUser,
                "HVAC Cleanroom Differential Pressure Test",
                "Airflow velocity measurements in progress on Floor 12 medical suites. Calibrating supply vs exhaust VAV dampers to maintain positive pressure differential (+15 Pa relative to corridor). Currently recording 4-hour trend log.",
                "Mechanical Room 12-B (30.2675 N, 97.7435 W)",
                now.minus(6, ChronoUnit.HOURS),
                "IN_PROGRESS");

        createNote(s4, demoUser,
                "Fire Suppression Main Riser Tamper Fault",
                "Zone supervisory alert triggered on central FACP for OS&Y valve RV-02. Physical inspection confirms valve is fully open and chained, but internal microswitch contact shows intermittent resistance. Replace monitoring switch assembly.",
                "Riser Room G-01, Marina Wing (30.2640 N, 97.7510 W)",
                now.minus(3, ChronoUnit.HOURS),
                "OPEN");

        createNote(s3, demoUser,
                "PV Tracker Motor Gearbox Oil Sample Analysis",
                "Quarterly fluid sampling on single-axis slew drive gearboxes (rows 1-20). Inspecting for metal particle wear and viscosity breakdown. Acoustic vibration sensor attached to detect worm gear backlash.",
                "Tracker Array Sector 2 (36.0402 N, 114.9825 W)",
                now.minus(14, ChronoUnit.HOURS),
                "IN_PROGRESS");

        createNote(s2, demoUser,
                "Substation Transformer Bushing Thermal Imaging",
                "FLIR infrared thermography completed on 13.8kV service step-down transformer. All terminal connections within +/- 2.5 C delta-T baseline under full ambient bridge lighting load. No hot spots found; inspection cert signed.",
                "Utility Vault UV-03 (30.2708 N, 97.7395 W)",
                now.minus(3, ChronoUnit.DAYS),
                "DONE");

        createNote(s4, demoUser,
                "Post-Tension Cable Duct Grouting Inspection",
                "Pre-grout pressure testing on tendon ducts TD-08 through TD-14 on transfer slab level 3. Duct TD-11 failed initial 50 psi air test; investigating coupling joint leakage near anchor head prior to thixotropic grout injection.",
                "Transfer Slab Level 3 (30.2645 N, 97.7505 W)",
                now.minus(1, ChronoUnit.HOURS),
                "OPEN");

        log.info("Demo data seeding completed successfully with 3 customers, 4 sites, and 8 field notes.");
    }

    private Customer createCustomer(String name, String contact, User user) {
        Customer c = new Customer();
        c.setName(name);
        c.setContactInfo(contact);
        c.setUser(user);
        return customerRepository.save(c);
    }

    private Site createSite(String name, String address, Customer customer, User user) {
        Site s = new Site();
        s.setName(name);
        s.setAddress(address);
        s.setCustomer(customer);
        s.setUser(user);
        return siteRepository.save(s);
    }

    private void createNote(Site site, User user, String title, String description,
                            String location, Instant dateTime, String status) {
        FieldNote n = new FieldNote();
        n.setSite(site);
        n.setUser(user);
        n.setTitle(title);
        n.setDescription(description);
        n.setLocation(location);
        n.setDateTime(dateTime);
        n.setStatus(status);
        fieldNoteRepository.save(n);
    }
}
