package au.gov.ga.geodesy.domain.model;

import java.util.ArrayList;
import java.util.List;

import org.apache.commons.collections.CollectionUtils;
import org.springframework.stereotype.Component;

import au.gov.ga.geodesy.domain.model.event.Event;
import au.gov.ga.geodesy.domain.model.event.EventPublisher;
import au.gov.ga.geodesy.domain.model.event.EventSubscriber;

@Component
public class MockEventPublisher implements EventPublisher {

    private List<Event> publishedEvents = new ArrayList<>();

    public void subscribe(EventSubscriber<?> subscriber) {
    }

    public void publish(Event... es) {
        CollectionUtils.addAll(publishedEvents, es);
    }

    public void handled(Event e) {
    }

    public List<Event> getPublishedEvents() {
        return publishedEvents;
    }
}
