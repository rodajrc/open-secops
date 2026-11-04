# Cyber Threat Intelligence Planning and Direction Demo

This file contains a simulated CTI engagement.

Read the file and follow the steps to do your own CTI simulation.

## Creating the case study with ChatGPT

For this demonstration, I am using ChatGPT 5.1 Thinking model to walk me through a case study, using the following prompt:

```
You are participating in a structured Cyber Threat Intelligence (CTI) simulation.

ROLE DEFINITIONS:
- **Me:** Cyber Threat Intelligence (CTI) practitioner.
- **You:** Sometimes, a key fictional stakeholder with both **strategic and operational authority** within a fictional organization. Other times, my senior CTI partner, who will be helping me out during the engagement.

SCENARIO:
We will execute a full CTI engagement following the **CTI Lifecycle**, beginning with the **Planning and Direction** phase and progressing through all subsequent phases.

OBJECTIVES OF THIS EXERCISE:
This simulation aims to practice the applied implementation of key CTI methodologies in a realistic but controlled environment. Specifically, the following capabilities will be exercised:

1. **Establishing Priority Intelligence Requirements (PIRs)**  
   - Used to guide collection efforts and align analysis with the organization’s core security needs. I will be using well-known frameworks including RedHat PIR v1.1 and Intel471 CU-GIR.

2. **Threat Actor Prioritization (TAP)**  
   - Identify and rank relevant threat actors based on intent, capability, targeting patterns, and alignment with the fictional organization’s profile.

3. **Strategic Analytical Techniques**  
   - Apply structured methods to minimize bias, validate assumptions, and strengthen analytical rigor.

4. **Prioritization of Tactics, Techniques, and Procedures (PTTP)**  
   - Identify, evaluate, and rank the most relevant TTPs likely to be used by prioritized threat actors against the organization.

INTERACTION GUIDELINES:
- As the stakeholder of the organization, you will introduce the fictional organization using a seed description that I will provide. 
- As my senior CTI partner, you will tell answer my CTI-specific questions and support my efforts in other to provide a better final result.
- As the stakeholder of the organization, you must behave as a real partner of the organization, enabling the simulation to feel authentic, dynamic and human.
- As the stakeholder of the organization, a back-and-forth interaction will take place. I may request additional details required to support intelligence development. You may choose what information to reveal based on what would reasonably be known, confidential, or unavailable within a real business scenario.
- As the CTI practitioner, I will share with you analytical updates, findings, and reasoning throughout the lifecycle.
- You will answer as a human and not as a computer or AI agent. I.e., you wont answer using bullet points or formatted data, but with verbal-like sentences and paragraphs.

FINAL OUTPUT:
- At the end of the simulated engagement, I will deliver a **final CTI report** aligned to your expectations.
- You will evaluate the report quality and classify it as:  
  **Above Expectations | Meets Expectations | Below Expectations**

THEATER SEED:
You will use the following _seed_ to plan the fictional organization. This is just an starting seed; you must elaborate upon to create a realistic story.
seed {
   _I am in a conference room with you for our first CTI planning meeting. I've just explained the idea of the CTI engagement to you. After careful attention, you accept the terms and conditions of the CTI engagement and provide me with the following information about your organization:_

   > Stakeholder: You know the entire company is betting on the LATAM expansion of our most important services over the next six months. We will be covering several countries including México, Brazil, Colombia, and Chile in the first year. The board is watching it, our investors are watching it, and I'm supposed to make sure it doesn't all blow up. 

   > Stakeholder: My problem is that I'm seeing all this chatter about other FinTechs getting hit. Every morning, it's a new report about a ransomware crew or some data breach. Then, last week, our own devs accidentally exposed an API key on a public GitHub repo. We caught it, thank God, but it proves we're vulnerable. We have to mantain our 99.9999% availability, or our prestige is going fall spectacularly.

   > Stakeholder: I can't protect everything. I have a limited budget and a small team. I need you to tell me what to worry about. Don't give me a 50-page report on 'all the threats.' Give me something actionable. I need to know who is actually going to come after us during this LATAM push, how they'll do it, and what we need to do to stop them. That's the 'subject' of this. Make sense?"
}

CONSIDERATIONS:
- Use the intent of my prompts to identify which persona (Stakeholder or senior CTI specialist) must reply.
- The stakeholder has the role of the CISO in the organization
- Create a moderate simulation in terms of difficulty and complexity. It must neither be overly straightforward, nor overly complex.
- When using accronyms, always include the concept in parenthesis after the accronym.

CONFIRMATION:
Once you are ready, think how to elaborate further the context of your organization using the provided _seed_, then acknowledge your roles as the stakeholder and senior CTI specialist so we may begin.
```

> [!TIP]
> If you like, adjust the prompt to make the simulation as your wishes. Maybe you rather prefer a black-box engagement, or a more simple scenario. Make your own simulation and learn from **DO IT YOURSELF**!

## AI Generated Case Study

Using the prompt presented earlier, the AI generated the following text, elaborating further the context of the organization. Read carefully and try to take notes of the most important aspects. 

```
We’re called NeuraPay, we are a mid-size FinTech headquartered in Madrid, with a strong presence in Spain and Portugal. Our core business is real-time payment orchestration and embedded finance for e-commerce and marketplaces. In practice, that means we sit between online merchants, banks, card schemes, and alternative payment methods, and we route transactions through the cheapest or most reliable rails in real time. Our customers are mid to large online retailers and platform companies; they integrate us via APIs (Application Programming Interfaces) into their checkout flows.

Technically we’re very cloud heavy. Our main stack runs on Google Cloud, with some legacy workloads still in a small private data center in Madrid that we have been trying to phase out. The transaction engine is a microservices architecture in Kubernetes, we have a public facing API gateway, and our merchant portal is a web app plus iOS and Android apps. Identity is based on OAuth 2.0 and OpenID Connect using a commercial identity provider. For data we have a mix of managed databases and a data lake that our data science team uses for risk scoring and fraud models. We use a handful of third parties for fraud detection, KYC (Know Your Customer), and AML (Anti-Money Laundering) screening, which means we are quite dependent on vendors and their own security posture.

Right now, most of our regulated business is under the European Union and United Kingdom frameworks, but the next big bet is LATAM. We have signed letters of intent with partners in México and Brazil and are in late stage talks in Colombia and Chile. The plan is to start processing real transactions in México and Brazil in about six months, then bring Colombia and Chile online in the following six months. For regulatory, we are working with local partners and using a “regulated partner plus technology” model at first, which complicates data residency and cross-border flows. The board’s message to me is very simple: this expansion must not create a headline-worthy incident. They are particularly allergic to availability issues because our brand promise is “always-on payments” and we advertise six nines of availability to our biggest merchants.

In terms of security maturity, we are not starting from zero. We have a small but competent security team: I have one security architect, one cloud security engineer, two people in application security, two in detection and response, and one GRC (Governance, Risk and Compliance) person. We do not have a full-time CTI function, which is why I am so interested in this engagement with you. Our logging and monitoring is decent on the cloud side, a bit patchier around some legacy systems and smaller vendors. We have an EDR (Endpoint Detection and Response) solution on corporate endpoints, cloud workload protection, and a central SIEM (Security Information and Event Management), but tuning and threat-driven use cases are still a work in progress.

Last week a developer accidentally pushed a repository with an exposed API key to a public GitHub repo. That repo was public for about three hours before our internal tooling flagged it and we rotated the keys. We did not see any obvious abuse, but frankly we did not hunt very deeply, which worries me. Earlier this year we had a minor outage caused by a misconfiguration in our infrastructure-as-code that brought down a subset of our production pods for about twenty minutes. It was not an attack, but it reminded everyone how fragile things can be. We also had a near-miss with a third-party fraud provider who had a suspected compromise, and for a few very tense days we were worried that our transaction enrichment data might have been at risk. That one ended up being contained on their side, but it showed us how much we rely on vendors.

My main strategic concerns going into LATAM are these: we are entering markets where certain ransomware groups, initial access brokers, and financially motivated threat actors seem very active, especially against FinTechs and digital banks; we will be more visible to local regulators and probably to local criminal ecosystems; we are going to be onboarding new local partners quickly, which introduces supply-chain and integration risk; and we are going to push our engineering teams pretty hard, which usually increases mistakes and misconfigurations.

Budget wise, I have some room, but it is not unlimited. I cannot boil the ocean. I cannot protect all assets to the same level. I need you to help me answer, in a very focused way, which threat actors I should lose sleep over for this LATAM expansion, which parts of our attack surface are most relevant in their playbooks, which tactics and techniques we should treat as “top tier” for preparation, and what concrete things I should prioritize, both defensively and in terms of monitoring and detection.

NeuraPay is betting big on LATAM, we are under pressure from the board and investors, we are not blind, but we are not bulletproof either. I do not want a generic list of “threats to FinTech.” I want something that feels like it was written for NeuraPay doing this specific expansion, in this timeframe, with this architecture and these constraints.
```

## Cyber Threat Intelligence Simulation

In the following sections, we will go through the CTI lifecycle. Keep in mind the formatting of the text; it has meaning:

1. Normal text is generally my own thoughs or comments.
2. _italics instructions of what you should do next_
3. **bold text highlights important CTI concepts or keywords**
4. > Quoted text is AI generated information
5. > _Italics quoted text highlights comments made by others_

> [!IMPORTANT]
> This file documents a simulation engagement. However, I will be updating this repository subproject directory with a real-life engagement experience, comparing both experiences to communicate the challenges faced and relevant insights.

### Task 1: Developing PIR leveraging well-known PIR development frameworks
---

In this section of the activity I will be guiding through the process of creating **Priority Intelligence Requirements** using both [RedHat PIR Framework v1.1](https://github.com/redhat-infosec/priority-intelligence-requirements-dev/blob/main/README.md) and [Intel 471 CU-GIR Handbook](https://github.com/intel471/CU-GIR/blob/main/README.md).

> [!NOTE]
> The actual Handbook must be requested directly in [Intel 471's Cyber Underground Handbook website](https://intel471.com/resources/cyber-underground-handbook)

PIRs are, according to Josh Darby in the FIRST CTI MEETING 2024

> _prioritized set of topics that your stakeholders need intelligence on in order to make better decisions_

Moreoever, Darby suggests that we SHOULD go through every relevant stakeholder in the organization that will use or receive the intelligence, and ask them what kind of intel they need, their concerns, and their needs. 

This interviewing process is very fruitful because stakeholder can provide experience-based information that minimizes the possibility of missing details or plugging gaps in the investigation.

Yet, it is important to understand how these frameworks are used in real world CTI engagements. 

For instance, Red Hat's approch for PIR development is both internal and external focused, requiring constant interaction with stakeholders and documentation to identify what they call the ELEMENTS, FUNCTIONS, and ASSETS of the organization (internal-focus), as well as potential ADVERSARY OPERATIONS (external-focus). As a result, the PIRs generated with this framework are organization-specific useful for strategic and operational stakeholders.

In contrast, Intel 471's approach to Intelligence Requirements uses an external; threat-centric approach, specifically tailored to Cyber Underground (CU) intelligence (i.e., ilicit forums, marketplaces, etc). Moreoever, this approach follows an strictly standardized process, that differentiates greatly with Red Hat's more flexible process.

> [!NOTE]
> Personally, I feel that Red Hat's approach to PIR development is kind of floppy; overly flexible that leds to uncertainty. It can be challenging to implement especially in the first attempts.

Regardless of these differences, we can make use of both methodologies to deliver better CTI results. Red Hat's approach is useful to define our first version of Intelligence Requirements, while Intel 471's approach can be useful to refine them into threat-centric PIRs and SIRs.

![Cyber Intelligence Tradecraft Report - CMU - Intelligence Requirements Inverted Pyramid](/media/cti_lifecycle-cti_demo-01-intelligence_requirements.png)

In summary, the combined approaches makes PIRs both business-relevant and threat-realistic

#### Step 1: Identify ELEMENTS, FUNCTIONS, and ASSETS of the organization

> [!TIP]
> Use [Red Hat's PIR Process v1.1 Template](https://docs.google.com/spreadsheets/d/1lnZOGX6Shm4NoT06APeRPXe4jEX0dCWDXTrmm60aOa8/edit?usp=sharing) to document the ELEMENTS

We start by reading [RedHat PIR Framework v1.1](https://github.com/redhat-infosec/priority-intelligence-requirements-dev/tree/main). In this methodology, we need to identify the **ELEMENTS** of the organization, derive the **FUNCTION**, and then map to its supporting **ASSETS**.

In Red Hat's documentation, the **ELEMENTS** are defined as **keywords, topics, or sentences** (derived from high-level strategic document) that represent:

- The organization **identity**
- The organization **strategy**
- The organization **mission** and **vision**

> [!NOTE]
> Altough it is supposed that the ELEMENTS are derived from high-level strategic documents, it is also true that these information can be derived from stakeholder engagements, interviews, and meetings.

Next, the **FUNCTION** of an element is a short phrase or keyword that provides context about what has to be **protected about that ELEMENT** to mantain it. To identify the function, ask yourself: _What must be true, security-wise, for this ELEMENT to continue existing?_

Finally, the **ASSETS** are the actual, tangible or non-tangible components in the organization that support the ELEMENT.

> [!NOTE]
> Using the AI generated case, an identity-related **ELEMENT** could be _"Real-time payment orchestration and embedded finance for e-commerce and marketplaces"_. Then, the **FUNCTION** could be _"Ensuring the continuous availability of the orchestration and embedded finance services"_. Finally, the supporting **ASSET** could be _"Propietary Software and APIs"_.

In summary, each step MUST narrow your focus. From an abastract idea (the ELEMENT) to a security-meaningul idea (the FUNCTION), to finally an actual tangible thing that MUST be protected (ASSETS)

So, the first step is to identify the ELEMENTS of the organization. Red Hat (and other sources) suggest asking the following questions:

- What features define your organization?
- What makes your organization unique?
- What are the most important aspects of your strategy?
- Why is anyone buying your products or services?
- Why are you ahead of competitors?
- What are your most important products or services?
- What kind of data is more important to you?
- How does your organization generate revenue?
- What does your organization need to make revenue?
- Where does your organization makes revenue?

_Using the information provided by the stakeholder (AI generated use case), what could be the ELEMENTS, FUNCTIONS and supporting ASSETS of the organization?_

> [!WARNING]
> Don't get spoiler, my answer is below this line. Try it yourself first, then compare.

| Element | Question | Rationale |
|---|---|---|
| EU-based mid-sized FinTech company with with business operations in EU, US, and currently moving to the Latino American market; currently most important strategic goal | How can I identify you? | NeuraPay's current strategy is expanding their business operations to another region |
| Real-time payment orchestration and embedded finance service for e-commerce and marketplaces with extremely high-availability | Why customers buy you? | NeuraPay’s core identity is being a real-time payment orchestration layer between online merchants, banks, card schemes, and alternative payment methods for mid to large e-commerce and platform companies. |
| Cloud-native, moving workloads from on-premises to cloud instances | What are your core characteristics? | NeuraPay's environment is cloud heavy, with a microservices transaction engine on Kubernetes, public API gateway, and merchant portal on Google Cloud. |
| Highly dependent on third-party platforms and systems for fraud detection and anti-money laundering | What are your current challenges? | NeuraPay's current concern is its dependency on third-parties and their security posture |

The next steps is to identify the FUNCTIONS and the supporting ASSETS for each one of the ELEMENTS. Red Hat does not provide a particular way to derive this context; therefore is up to you.

> [!TIP]
> Personally, I like this way to derive FUNCTIONS:
> 1. First interpret your ELEMENT. _Why is there?_
> 2. Translate the ELEMENT into a FUNCTION by asking the question: _“What needs to be protected to preserve this element?”_
> 3. Identify ASSETS by asking yourself: _“What people, systems, data, or external capabilities supports the ELEMENT's FUNCTION?”_

_Using the information provided by the stakeholder (AI generated use case) and the ELEMENTS you identified, interpret each ELEMENT to find its FUNCTION?_

> [!WARNING]
> Don't get spoiler, my answer is below this line. Try it yourself first, then compare.   

| Element | Interpretation | FUNCTION |
|---|---|---|
| EU-based mid-sized FinTech company with with business operations in EU, US, and currently moving to the Latino American market; currently most important strategic goal | Public identity; this ELEMENT is basically the company itself | All business units must be protected for uninterrupted operations and LATAM expansion  |
| Real-time payment orchestration and embedded finance service for e-commerce and marketplaces with extremely high-availability | Core-service; main source of revenue | Continuous availability of payment orchestration and embedded service; minimal down-time |
| Cloud-native, moving workloads from on-premises to cloud instances | Technical characteristic of the business; they are moving workloads into the Cloud because almost everything runs in the cloud | Workloads must remain up-and-running to ensure business continuity; protect migration tasks |
| Highly dependent on third-party platforms and systems for fraud detection and anti-money laundering | Known concern or challenge | Secure third-party software and platforms |

Once you have the ELEMENTS and its derived FUNCTIONS, you can start mapping the supporting ASSETS.

> [!TIP]
> Again, Red Hat's methodology does not provide a clear standardized way to map internal ASSETS, so its up to you. However, it is not recommended to be overly specific. That may lead to biases and gaps
>
> My way to do it is to identify ASSETS from stakeholder or derive them from the high-level strategic documentation that Red Hat methodology suggest to look for.
>
> You can group assets in categories or "buckets", such as _Systems and Technology_, _Data and Propietary Information_, _People_, _Processes_, etc. Its up to you!
>
> Below is an example

| Category                    | Assets identified                      |
| --------------------------- | -------------------------------------- |
| **Systems and Technology**  | Kubernetes, API gateway, CI/CD       |
| **Data**                    | Transaction data, fraud scoring models |
| **People**                  | Developers, cloud security engineers   |
| **Internal Processes**      | Logging and Monitoring                 |
| **External Dependencies**   | Fraud vendors, regulated partners      |

_Using the information provided by the stakeholder (AI generated use case), the ELEMENTS, and derived FUNTIONS, can you identify the ASSETS that support each ELEMENT's FUNCTION?_

> [!WARNING]
> Don't get spoiler, my answer is below this line. Try it yourself first, then compare.

| Element | FUNCTION | ASSETS |
|---|---|---|
| EU-based mid-sized FinTech company with with business operations in EU, US, and currently moving to the Latino American market; currently most important strategic goal | All business units must be protected for uninterrupted operations and LATAM expansion  | - Misc: All systems and technology assets - Internal Process: Incident Response |
| Real-time payment orchestration and embedded finance service for e-commerce and marketplaces with extremely high-availability | Continuous availability of payment orchestration and embedded service; minimal down-time | - Systems and Technology: Cloud Resources - Data: Transaction Data |
| Cloud-native, moving workloads from on-premises to cloud instances | Workloads must remain up-and-running to ensure business continuity; protect migration tasks | - Systems and Technology: CI/CD - Systems and Technology: Cloud Resources - People: Cloud Engineers |
| Highly dependent on third-party platforms and systems for fraud detection and anti-money laundering | Secure third-party software and platforms | - External Dependencies: Third-party services and solutions - Data: Contracts with partners and third-parties |

#### Step 2: Map ELEMENTS to plausible ADVERSARY OPERATIONS

The next step is to identify the most plausible **ADVERSARY OPERATION** to each ELEMENT of the organization. Red Hat's approach is simple:

1. For each ASSET that supports an ELEMENT's FUNCTION, identify the two most impactful **ADVERSARY OPERATION**.
2. Assess each **ADVERSARY OPERATION** against the likelihood of occurence and the impact (this is essentially a **Risk Assesment** process)

In the context of the Red Hat framework, **ADVERSARY OPERATIONS** are custom buckets that describe a particular way of threat actors to operate against your organization. According to Red Hat:

> _We found that existing classifications of cyber attacks didn't quite fit our needs, leading us to develop our own classification. This classification focuses on the impact of cyber attacks on business operations and also on applicability of the terms used in the classification in threat intelligence platforms (TIPs), which is vital for operationalization._

> [!NOTE]
> If you are wondering how everything stick together, here is the logic summarized:
> 1. An **ELEMENT** is tied to a **FUNCTION** that describes _what needs to be secured_ to keep the **ELEMENT** alive
> 2. An **ELEMENT** depends on one or more **ASSETS** that supports the **ELEMENT**'s **FUNCTION**
> 3. **ASSETS** can fail in one or more ways, affecting an **ELEMENT**'s FUNCTION
> 4. **ADVERSARY OPERATION**(s) can force failures in **ASSETS**, negativelly affecting a **FUNCTION**, and therefore harming the **ELEMENT**

Personally, I think this is another example of the flexibility of Red hat's framework for developing PIRs. It is not bad nor good; it is just a way of do it.

Regardless of how you define your **ADVERSARY OPERATIONS**, you may be asking "How can I weight which is (are) the most impactful operation(s)? Keep in mind, again, that this is my way to do it. It works for me, and it may or not work for you.

First, understand the **business context** (location and sector), and the **business needs** (short and long term goals). In this case, for the **FinTech** case study, we know the following details:

> [!NOTE]
> Don't worry about the weird numbers that look like IDs in some of my following responses. I will be explaining that later.

> [!WARNING]
> Don't get spoiler, my answer is below this line. Try it yourself first, then compare. 

- **Sector**: 6.1.3.4 Payment processing industry (Financial Services)
- **Regions of operation**: 6.2.4 Europe (Spain and Portugal), 6.2.6.5 United States, 6.2.3 Central America (México), and 6.2.8 South America (Brazil, Colombia, and Chile)
- **Most important need**: Expansion to Latin America Market in the next 6 months to Mexico and Brazil, and Colombia and Chile in the next 18 months
- **Important needs**: Brand promise; continuous delivery of highly-available financial services to trusted partners and clients, in EU, US, and LATAM

Second, try to place yourself in the hat of a malicious threat actor. Ask yourself the question: _Write 2 or 3 reasons about why would you want to target FinTech Considering the context and goals of the organization._

> [!WARNING]
> Don't get spoiler, my answer is below this line. Try it yourself first, then compare. 

- If I ever wanted to attack FinTech, a Financial organization (**Target industry**), I would do it for Financial Gain (**Motivation or intent**)
- If I ever wanted to attack FinTech for non Financial Gain motivations, I will do it for Corporate Surveillance.

> [!NOTE]
> Intent is also subjetive. But a quick Google Search is useful to set a baseline. For instance, some examples of general intent cateogories are:
> - Financial Gain
> - Surveillance and Espionage
> - Social Causes and Hacktivism
> - Political Interest and Influence
> - Personal Grievances and Disruption

Third, ask yourself (or the stakeholders), _how the ASSETS can fail so that the ELEMENTS function is affected?_ 

> [!TIP]
> I think that a good way to proceed from here is to start writing drafts of the Intelligence Requirements. You can use the formula:
> 
> What **ADVERSARIAL OPERATIONS** can target `{ASSET}`, causing `{NEGATIVE EFFECT}` that affects `{BUSINESS GOAL}`

> [!WARNING]
> Don't get spoiler, my answer is below this line. Try it yourself first, then compare. 

- What **ADVERSARIAL OPERATIONS** can target the real-time payment orchestration and embedded finance service crtiical service, causing operational disruption, which ultimately affects the expansion to the Latin America market?
- What **ADVERSARIAL OPERATIONS** can target cloud resources of the organization, affecting the continuous delivery of the highly-available payment orchestration and emdded financial service, damaging our brand promise and partner trust?
- What **ADVERSARIAL OPERATIONS** can target our CI/CD pipeline, which is critical for on-premise asset migrations to our cloud provider, partially halting or completely stopping the goal of expansion into the LATAM market?
- What **ADVERSARIAL OPERATIONS** can target our supply chain and third-party services, limitating our capabilities and efficient service delivery, hurting or slowing our expansion into the Latin America market and damaging our brand image?

> [!TIP]
> Remember that you don’t need perfection. You just need 2 serious adversary operations per element that are:
> - plausible for the sector and region,
> - aligned with its function, and
> - painful enough that the stakeholder would genuinely care.

Finally, just answer the question. I personally like to review [Mitre ATT&CK matrix](https://attack.mitre.org/) and [Intel 471 Cyber Underground General Intelligence Requirements Handbook](https://intel471.com/resources/cyber-underground-handbook). Essentially, _for each Intelligence Requirement, which TTPs form a well-defined type of **ADVERSARIAL OPERATION** that aligns with the intent of a threat actor?_. Intel 471 General Intelligence Requirements 5 can be useful to find the relevant questions you need to answer to produce better results.

> [!WARNING]
> Don't get spoiler, my answer is below this line. Try it yourself first, then compare.

- What **ADVERSARIAL OPERATIONS** can target the real-time payment orchestration and embedded finance service crtiical service, causing operational disruption, which ultimately affects the expansion to the Latin America market?
   - **GIR 5**:
      - 5.2.12.2 Denial of service (DoS) technique
      - 5.5.7 Sabotage
   - **Mitre ATT&CK**:
      - T0814 Denial of Service
      - T1485 Data Destruction
      - T1529 System Shutdown/Reboot
   - **Adversarial Operations**: 
      - Ransomware and Sabotage
      - Denial of Service and Availability
- What **ADVERSARIAL OPERATIONS** can target cloud resources of the organization, affecting the continuous delivery of the highly-available payment orchestration and emdded financial service, damaging our brand promise and partner trust?
   - **GIR 5**:
      - Credential theft and abuse for access to cloud environments.
      - Abuse of cloud management APIs to disrupt services.
   - **Mitre ATT&CK**:
      - Techniques related to valid accounts, cloud credential theft, and destructive operations against cloud resources.
   - **Adversarial Operations**: 
      - Account Compromise and Phishing
      - Ransomware and Destructive Intrusion
- What **ADVERSARIAL OPERATIONS** can target our CI/CD pipeline, which is critical for on-premise asset migrations to our cloud provider, partially halting or completely stopping the goal of expansion into the LATAM market?
   - **GIR 5**:
      - Compromise of software build pipelines and DevOps tooling.
      - Abuse of developer or CI/CD credentials to deploy malicious code or infrastructure.
   - **Mitre ATT&CK**:
      - Techniques around build-system poisoning, trusted relationship abuse, and staged deployment of backdoored images or IaC.
   - **Adversarial Operations**: 
      - Supply-Chain Compromise.
      - Ransomware and Sabotage
- What **ADVERSARIAL OPERATIONS** can target our supply chain and third-party services, limitating our capabilities and efficient service delivery, hurting or slowing our expansion into the Latin America market and damaging our brand image?
   - **GIR 5**:
      - Compromise of third-party providers that integrate with payment platforms.
      - Financial fraud operations that exploit weaknesses in fraud/AML decisioning.
   - **Mitre ATT&CK**:
      - Techniques abusing trusted relationships with external services.
      - Techniques aimed at manipulating detection and response or bypassing anti-fraud mechanisms.
   - **Adversarial Operations**: 
      - Supply-Chain Compromise
      - Account Compromise and Phishing

